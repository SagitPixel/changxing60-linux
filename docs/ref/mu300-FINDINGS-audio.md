### 24. No internal audio hardware
* The DT enables a sound card, the UMP9620 codec and an AW883xx amplifier at `6-0034`, and Android disables audio.
  With `i2c-dev`, nothing answers at 0x34 (nor at the bq2560x address 0x6b), and there is no AGDSP firmware partition.
  The board has no speaker path; only Bluetooth or USB-host audio devices are possible.
* **A virtual card is enough for software that only needs a device.** The stock config leaves `SND_DRIVERS` off,
  which is what gates `snd-aloop` and `snd-dummy`; the fragment turns it on and builds both as modules.
  `snd-aloop` then gives card 0 with two PCM devices of eight substreams each - write to `hw:0,0` and the same
  audio comes back on `hw:0,1` - which is what a program bridging a call on the device needs to hand audio
  between two programs. Verified on the device: `/proc/asound/cards` shows `Loopback`, and `/dev/snd` has
  `controlC0`, `pcmC0D0c/p` and `pcmC0D1c/p`. It carries no cellular voice by itself; that still needs the AGDSP
  path below.
* **The whole Unisoc audio stack now builds and loads on this kernel** - `kernel/build-audio.sh` produces 23
  modules from the realme `unisoc-5.4` kernel_modules tree, and all 23 insmod cleanly: the DSP loader
  (`sprd_audcp_boot`), `agdsp_access`, `audio_sipc`, `audio_mem`, the VBC v4 voice DAI
  (`snd-soc-sprd-vbc-v4`, `snd-soc-sprd-vbc-fe`), the UMP9620 codec, the PCM platform and the machine card.
  Nothing in the kernel config had to change: `CONFIG_SND_SOC`, `SND_SOC_COMPRESS` and `SND_SOC_TOPOLOGY` are
  already built in. The build's three pitfalls are written up in that script.
* The device tree is not the problem either, which was the expectation. `sound@0` is `status = "okay"` and
  carries `sprd-audio-card,name`, `,routing`, `,headset` and `sprd,syscon-agcp-ahb`; `audiocp_boot` has its
  full register set - `bootvector`, `bootaddress_sel`, `corereset`, `coreshutdown`, `sysreset`, `sysstatus`,
  `deepsleep`. The machine driver finds it: the log shows `vbc-rxpx-codec-sc27xx sound@0`, exactly the binding
  the community Android modules use.
* **What stops it is the DSP itself.** `sound@0` probes and defers for ever, because the DAI link cannot be
  parsed until the audio SIPC channel to the DSP exists, and that channel reports
  `[Audio:SMSG] ERR:aud_smsg_ch_open ipc ENODEV`. The DSP is not running, and it cannot be started here: this
  board's device tree has no `audio-mem`/`audiodsp-mem` reserved region (another UMS9620 device uses
  0xaf700000 3 MiB and 0xafa00000 6 MiB), and there is no AGDSP firmware partition on the device. The
  community Android flow supplies both - an image taken from a different device, written to
  `/sys/devices/platform/audiocp_boot/agdsp` between `stop` and `start`.
* **The gap is exactly one device tree property.** `audio-mem-mgr` on this board carries every Unisoc audio
  address there is - `sprd,cmdaddr`, `sprd,smsg-addr`, `sprd,shmaddr-dsp-vbc`, `sprd,offload-addr`,
  `sprd,ddr32-dma`, `sprd,iram-ap-base`, `sprd,iram-dsp-base` and a dozen more - and is missing only
  `memory-region`. `audio_mem` reads that property as two phandles (`of_parse_phandle(np, "memory-region", 0)`
  and `1`) pointing at reserved DDR; without them `audio_mem_alloc(MEM_AUDCP_DSPBIN)` has nothing to hand
  `sprd_audcp_boot`, so the image cannot be written and the DSP never starts. ZTE kept the whole audio
  description and removed the reservation, which is consistent with a board built without a speaker.
* There is no firmware file to look for, incidentally: `sprd_audcp_boot` has no `request_firmware()` at all.
  Userspace writes the image into the `agdsp` sysfs attribute in chunks (`agdsp_store` memcpys into
  `base_addr_virt`) between `stop` and `start`. Searching the F50's `super` for an `agdsp`-shaped filename
  finds only slog config (`agdsp.conf`) and dump-region names (`AGDSP_MEM`, `AGDSP_PCM`) - no image.
* **The memory map has a hole of exactly the right size in exactly the right place.** The F50 reserves up to
  `ae8fffff` (`ch_ddr`) and then nothing until `b0000000` (`logobuffer`), leaving about 23 MiB free. The
  addresses another UMS9620 device uses for audio - 0xaf700000 (3 MiB) and 0xafa00000 (6 MiB) - both fall in
  that hole, and the second ends precisely where `logobuffer` begins. That is a strong sign they are the right
  addresses for this SoC family rather than a guess.
* **The reservation works, and it unblocked the DSP.** `of-reserved-mem-add.patch` reserves the two ranges
  (`CONFIG_OF_RESERVED_MEM_ADD="0xaf700000,3M;0xafa00000,6M"`) and `audio-mem-fixed-region.patch` lets
  `audio_mem` be told where they are. Measured on the device after a reboot into that kernel:

      OF: fdt: Reserved memory: reserved 0x00000000af700000 size 0x0000000000300000 (reserved_mem_add)
      OF: fdt: Reserved memory: reserved 0x00000000afa00000 size 0x0000000000600000 (reserved_mem_add)
      [Audio:MEM] memory-region 1 from module parameters: 0xaf700000 size 0x300000
      [Audio:MEM] dsp_bin (addr, size): (0xaf700000, 0x300000)
      [Audio:SBLCK] audio_sblock_create: p_rxblks[6].addr 0xaf71d060
      [Audio:SMSG] aud_smsg_send: dst=1, channel=3

  The last two lines are the point: the audio SIPC channel that used to answer `ENODEV` now allocates its
  blocks inside the reserved region and sends to the DSP. `mu300-audio-dsp` loads the 23 drivers with the right
  parameters.
* The card now parses **57 of its 58 dai links**, where before it deferred at link 0 and never moved.
  `BE_VOICE_PCM_P` - the back end a program bridging the call needs - parses fine. It stops on the last one,
  `BE_FAST_P_SMART_AMP`, with `get dai name for 'codec' failed!(-517)`: that link wants the smart amplifier,
  which this board does not have (nothing answers at I2C 0x34, and the DT's own `sprd,spk-ext-pa-info` count
  fails with -22). Links whose `codec` phandle is simply missing already fall back to a dummy codec - the
  driver says so - but a codec that *defers* is treated as fatal, and `asoc_sprd_card_probe` gives up, so no
  card registers and nothing re-probes.
* `sprd-card-dummy-on-defer.patch` handles the smart amplifier: `dummy_on_defer=1` lets a codec that keeps
  deferring fall back to the dummy the way a missing one already does. It applies **only to the codec** -
  `args_count` is NULL exactly on the codec call, and handing the cpu dai a dummy instead of deferring kills
  the card at link 0 instead of 57, which is how that was found.
* The firmware exists and is 6 MiB, which settles which region is which: `l_agdsp_a.img` goes in
  `audiodsp-mem` at 0xafa00000, and `audio-mem` at 0xaf700000 3 MiB is the shared memory. The driver confirms
  it - `sprd_audcp_boot audiocp_boot: base_addr_phy = 0xafa00000, bin size = 0x600000`. There is no image in
  this repository and there cannot be: the project publishes no proprietary files, and unlike the Wi-Fi and
  modem firmware there is no copy on the device to take.
* **The card registers: `sprdphone-sc2730`, 19 PCM devices, `FE_ST_VOICE_PCM_P` at card 1 device 53.** That
  is the same card the community Android modules produce, and that endpoint is exactly what call-audio programs look
  for. `mu300-audio-dsp load` does it in one command and it survives a reboot.
* **The last thing in the way was the DMA engine, and nothing says so.** `CONFIG_SPRD_DMA` is a module and
  nothing pulls it in, so `/sys/class/dma` is empty, `sprd-pcm-audio` defers for want of a channel, its
  component never registers, and `snd_soc_register_card` fails with `ASoC: failed to init link FE_NORMAL_AP01:
  -517` - a message that names a link and says nothing about DMA. Loading `virt-dma` and `sprd-dma` brings up
  two controllers with sixty channels, and `sprd-pcm-audio`, `sprd-pcm-iis` and `sprd-compr-audio` register
  behind them.
* The card's own probe runs before those components exist and **is not retried**: it returns 0 even when
  `snd_soc_register_card` deferred, so nothing re-probes it. Binding `sound@0` again by hand once everything
  is up is what completes it.
* `mu300-audio` brings the card up at boot on both systems - a procd `boot()` that backgrounds itself, because
  binding takes about half a minute of waiting on probes and busybox init does not spawn the consoles until
  sysinit returns. It runs `load` and never `start`, so nothing at boot can reach the reboot below.
* **The reboot below is no longer reproducible, and the explanation given for it does not hold.** Android's own
  module writes the firmware with `sound@0` *unbound* and binds afterwards; doing the same here did not reboot
  the device either, so "the card must be registered first" is not the rule it was written up as. Kept below as
  the record of what was actually measured at the time. What it is not is a reason to avoid `start`.
* **Starting the DSP reboots the device only when the card is not registered.** Measured both ways: with
  `sprdphone-sc2730` up, writing the firmware and the reset registers leaves the device running (uptime went
  from 972 s to 1225 s across the attempt); with the card missing - which is what happens before `sprd-dma` is
  loaded - the console shows an orderly CPU shutdown and `reboot: Restarting system` seconds later. It is a
  deliberate reboot from userspace, not a panic. Registering the card is what exercises `agdsp_access_enable`,
  so with no card the AGDSP power domain is never brought up and `start_store` writes `RESET_SEL`, `CORE_RESET`
  and `SYS_RESET` into a domain that is off. `mu300-audio-dsp start` now refuses unless the card is present.
  The register sequence itself was compared against the driver and the device tree and is not the problem:
  `reset_sel` 0x0ba8/0xffffffff, `corereset` 0x0b88/0x1, `sysreset` 0x0b98/0x400000, `bootprotect` 0x0078 with
  the 0x9620 magic, and the boot vector is written - "dsp reboot by DDR!" means the `dsp-reboot-mode` property
  is absent and the mode is **0**, which is the branch that sets the vector.
* **`status` is a struct, not a number**, which is why a working DSP looked like a failed one:
  `struct audcp_status { u32 core_status; u32 sys_status; u32 sleep_status; }`, and `sys_status` is 0 for
  "power up finished" and 7 for "power off". After the first firmware write and start it read
  `core=0 sys=0 sleep=6` - the DSP was up. Read it with `od -An -tu4 -N12`.
* **The start is once per boot, and that is all it needs to be.** From the cold state (`sys=7 sleep=0`) it
  works every time; re-running it on a DSP that has already been booted leaves `sys=7` with every step still
  reporting success. `mu300-audio` does it once at boot, after the card, which is the only ordering that is
  safe anyway.
* **`sys` flips between 0 and 7 on its own** - that is the DSP's power management, not a failure. Reading the
  status at an arbitrary moment says little; what says the path works is opening the endpoint:

      [ASoC: PCM ] sprd_pcm_preallocate_dma_ddr32_buffer alloc size = 0x20000
      [Audio:MEM] audio_mem_alloc mem_type=5 addr = 0xaf725000, size=0x20000
      [ASoC: PCM ] sprd_pcm_close FE_DAI_ID_VOICE_PCM_P Close Playback

  `/dev/snd/pcmC1D53p` opens and closes cleanly and takes its DMA buffer from the reserved region. What has
  not been done is a call carrying audio through it.
* **The card registers with every route switched off**, and that is the last thing in the way of a PCM. Opening
  one gives `aplay: Unable to install hw params`, which reads like a driver that cannot do 16-bit 48 kHz — it
  can; the real line is a few above it in dmesg:

      FE_NORMAL_AP01: ASoC: no backend DAIs enabled for FE_NORMAL_AP01

  The DPCM front ends are joined to their back ends by ~70 `S_..._SWITCH` mixer controls, all off at probe
  (`S_NORMAL_AP01_P_CODEC SWITCH`, `S_VOICE_PCM_P SWITCH`, `S_VOICE_P_CODEC SWITCH`, …). Android's HAL sets
  them from its own configuration and there is nothing to inherit here. `mu300-audio-dsp routes` sets the ones
  this board can use; with the route on, `hw_params` installs and `BE_DAI_ID_NORMAL_AP01_CODEC` comes up.
* **An idle AGDSP reads exactly like one that never started.** The power domain is only up while something is
  using it, so `sys_status` is 7 whenever no PCM is open - and `mu300-audio-dsp start` used to check it one
  second after the firmware write and report "the DSP did not come up" over a load that had gone fine.
* **Powered is not running, and confusing the two cost an evening.** Opening a PCM produces

      [sprd-aud-agdsp] agdsp_access_enable, ap_access_ena_reg (wake up dsp) val = 0x20
      [sprd-aud-agdsp] agdsp_access_enable, ap_access_ena_reg (wake up done) val = 0x20

  with no `wait agdsp power up timeout`, and `status` then reads `core=0 sys=0`. On its own that only says the
  power domain came up, which `agdsp_access_enable()` does through the PMU whether or not the core has anything
  to execute. It is not a test of the firmware.
* **`/dev/audio_dsp_log` is not that test either, and believing it was cost an evening and a wrong writeup.**
  It returns nothing (`sblock_receive wait interrupted`, `dsp_log_read: failed to receive block`) on a DSP that
  is demonstrably running: this firmware simply does not log. "The log is silent, so the core is dead" was
  stated here as a measurement and it was an inference, from one negative signal.
* **The test that does settle it is `aud_send_cmd`'s own trace**, because its exit line is only reachable when
  the DSP replied - an unanswered command retries four times and then leaves through `failed to get command`,
  never printing it (`audio-sipc.c` around line 700). What the kernel actually logs here is

      [Audio:SIPC] aud_send_cmd out,cmd =5 id:0 ret-value:0,repeat_count=1

  `repeat_count=1` is a reply on the first attempt. **The AGDSP is running and answering.** `mu300-audio-dsp`
  reports power-up and liveness separately, and uses this for the second.
* **Android does not get further than this either**, which is worth knowing before spending a week on it. Its
  AudioCP times out too - from `f50_bluetooth_microphone_experimental`'s `service.sh`:

      # AudioCP still times out on F50 even with the donor memory layout. Keep the
      # probe manual so a failed 104-second codec loop cannot stall every boot.

  and the Whale HAL module's README lists, as explicitly outside what it achieves: cellular call routing
  through the F50's own earpiece, speaker and microphone, and **apps bridging cellular RX/TX
  through `AudioRecord`/`AudioTrack`** - which is exactly the thing a program bridging the call needs. What does work there
  is media audio, system sounds, and cellular calls over a **Bluetooth headset's SCO link**, which does not go
  through the AGDSP at all. `S_VOICE_P_BT` and `S_VOICE_C_BT` exist in the mixer, so that route is reachable
  from here too, and BlueZ already runs on this device (section 25).
* **Every register the AP is supposed to write is written correctly**, read back from the silicon with
  `tools/mu300-peek` (this kernel has `# CONFIG_DEVMEM is not set`, so there is no `/dev/mem` and a small
  module is the only way to look). The two syscons are `/soc/syscon@64900000` (phandle 2) and
  `@64910000` (phandle 4), both `sprd,ums9620-glbregs`, and after `start`:

  | | address | read back | |
  |---|---|---|---|
  | bootprotect | `0x64900078` | `0x80009620` | the 0x9620 magic, unlocked |
  | bootvector | `0x64900140` | `0x57d00040` | `(0xafa00000 + 0x80) >> 1`, exactly right |
  | bootaddress_sel | `0x64900144` | `0x00000001` | set |
  | sysshutdown / coreshutdown | `0x649103d0` / `0x3d4` | bit 25 clear | force-shutdown released |
  | corereset / sysreset / reset_sel | `0x64910b88` / `0xb98` / `0xba8` | all 0 | resets released |

  And the firmware really is in DDR: peeking `0xafa00000` shows `SharkL5_AUDCP_20…` where the file has it.
* **Look at the right shared memory.** `0xaf700000` is `sprd,ddr32-dma`, a DMA buffer, and it holds only the
  AP's own ring descriptors - staring at it and concluding "the core writes nothing" was another wrong
  inference. The AP↔DSP mailbox is elsewhere, and the F50's own `/audio-mem-mgr` node gives every address:

      sprd,ddr32-dma        0xaf700000 + 0x200000      sprd,cmdaddr          0xaf980000 + 0x400
      sprd,ddr32-dspmemdump 0xaf900000 + 0x80000       sprd,smsg-addr        0xaf980400 + 0xa10
      sprd,iram-ap-base     0x56800000                 sprd,shmaddr-dsp-vbc  0xaf981210 + 0x1400

  `start` zeroes those areas (`sprd_audcp_memset_communication_area`), and they fill in again once the domain
  powers: the ring header returns at `0xaf980400` with `0x07` and `0x01` appearing after it. That node also
  settles the naming scare for good - its own `compatible` is `unisoc,audio-mem-sharkl5`, on a board whose
  syscons are `sprd,ums9620-glbregs`. SharkL5 is Unisoc's lineage label here, not a different chip.
* **The profiles load from `/lib/firmware`, and `tools/vbc-profile` builds them.** Writing 1 to
  `Audio Structure Profile Update` / `DSP VBC Profile Update` / `CVS Profile Update` gives
  `vbc_profile_loading, return 0` for blobs converted from the vendor XML, and writing a mode to the matching
  `… Profile Select` then applies it (`vbc_profile_try_apply, now_mode[0]=0`) and sends the DSP a 620-byte
  parameter payload it acknowledges. The one thing about the XML that is not guessable: **`id` is an offset
  into the whole mode array, not into the mode it appears in** - mode 1's first field is at `struct_size`,
  mode 2's at twice that. Reading it as per-mode puts every field but mode 0's out of range, and the converter
  checks the two readings against each other (`byte_off // len_mode` against the element's own `mode=`) so the
  mistake cannot come back silently.
* **`[MCDT] agcp mcdt clocl not available` means what it says: MCDT is switched off.** It is easy to dismiss,
  because it is logged during teardown, after `agdsp_access_disable()` has dropped the power domain - which is
  where it was first seen, and it was written off here as an artifact of that. It is not. `MODULE_EB0_STS` at
  `0x64900000` (the AGCP AHB syscon, phandle 2) read `0x2063e2d1`, and `BIT_MCDT_EN` is `BIT(12)`:

      0x2063e2d1  ->  bits 15..12 = 0xe = 1110  ->  bit 12 clear

  `check_agcp_mcdt_clock()` therefore returned false and **every** MCDT register access was skipped, setup
  included - `mcdt_reg_read`, `mcdt_reg_raw_write` and `mcdt_reg_update` each return early without touching the
  hardware. `mcdt_dac_dma_enable … mcdt_dma_ap_channel=1` still prints, which is what makes it look healthy.
  Nothing in the audio drivers ever writes that bit; they only read it. Setting it (bit 12 at `0x64900000`,
  while the AGDSP domain is powered, since the register lives inside it) silences the errors, and it persists.
  `AUD_EB_V2` (21), `AUDIF_CKG_AUTO_EN_V2` (22) and `VBC_EB_V2` (15) were already set.
  * This matters for the **voice** path, which is the one that runs through MCDT. Normal playback does not: its
    trace has no MCDT lines at all and goes through `AP01_PLY_FIFO` in VBC instead, so the MCDT bit is not what
    stalls media audio.
* **The profiles are a *call* structure, not a media one**, which is worth knowing before spending time on
  media playback. `audio_structure.xml`'s modes are Handset, Handsfree, Headset4P/3P, BTHS, BTHSNREC,
  TypeC_Digital, HighVolume and Hac, each with NB1/NB2/WB1/WB2/SWB1/FB1/VOIP1 (modes 0-62), plus four
  Loopback modes (63-66). There is no media mode at all.
* **`param_id` in the select value is load-bearing.** The value is `(mode << 24) | (param_id << 16) | dsp_case`,
  and with `param_id` 0 the apply does nothing visible. With `0x5e` - which is what a working device of this
  family carries in both selects - the driver copies the mode into the DSP's shared memory:

      [Audio:SIPC] cmd =11 sharemem_info.id=…, phy_iram_addr=0xaf981210, size=0x6c4

  and `0xaf981210` is `sprd,shmaddr-dsp-vbc` from the device tree. `mu300-audio-dsp profiles [MODE]` does the
  whole sequence.
* **A working reference exists and is worth borrowing from.** A ZTE MU5358 (ums9632, a later VBC generation)
  registers the same `sprdphone-sc2730` card and does carry call audio. Diffing `tinymix` on it between idle
  and an active call shows exactly 18 controls move, and they are all routing and output: `DSP_VOICE_PLAY`,
  every input of the `VBC_DA0_CODEC` mixer at once (VOICE, FAST, MM, OFFLOAD, LOOP, VOIP, AP23, FM),
  `agdsp_access_en`, and the codec's own `AO Mixer AOL/AOR`, `DA AOR`, `EAR_AOL Mixer DACAOL`, `Earpiece
  Function` and `Speaker Function`. Its names belong to a newer VBC, but the shape carried over: turning on
  *every* `S_*_CODEC SWITCH` here, not just the scene's own, plus that codec tree and `agdsp_access_en`, was
  tried and changed nothing.
  * Neither the F50's own Android nor a ZTE U30 Air (the same ums9620, and the kernel this project builds
    against) has any audio at all - no card, no audio modules, no reserved memory, and the same
    `audio-mem-mgr` node with no `memory-region`. So within the UMS9620 hotspots there is no working example
    to copy; the MU5358 is a different chip.
  * The U30 Air is still useful: `/odm/etc/audio_params/sprd/` on it holds the **native** UMS9620 parameter
    XMLs (`audio_structure`, `dsp_vbc`, `cvs`, `dsp_smartamp` and more), which are a better source for
    `tools/vbc-profile` than the community package's donor copies from another device.
* **Where it actually stops** - measured from `/proc/asound/card1/pcm0p/sub0/status` during a playback attempt:

      state: RUNNING   hw_ptr: 160   appl_ptr: 24160   avail: 0      (unchanged from t=2s to t=10s)

  The DMA advances **once**, by 160 frames, and then freezes with the application blocked on a full buffer,
  until ALSA gives up and `aplay` reports `write error: I/O error`. 160 is exactly the `burst:160` the driver
  programs, and `/proc/interrupts` shows both `sprd_dma` lines at zero throughout: the DMA does one burst and
  then waits for a request from the VBC FIFO that never comes.
  * **The VBC registers say the AP side did its job.** Read during a stalled stream (safe only then - see the
    warning above), at `0x56510020`:

        AUD_EN 0x00000300   AUD_DMA_EN 0x00000003   PLY_FIFO0_STS 0x000024a1   PLY_FIFO1_STS 0x000024a1
        AUD_INT_EN 0x00000004   AUD_INT_STS 0x00000010

    The playback FIFO is enabled, both DMA channels are on, and the FIFO's low nine bits read 0xa1 = **161
    words sitting in it, unchanging** - which matches hw_ptr's 160 frames exactly. The DMA filled the FIFO
    once; nothing is taking data out of it. In this design that consumer is the DSP.
  * Parameters and modes are exhausted as an explanation. Both parameter sets were tried with the working
    `param_id` 0x5e - the community's donor set from a ZTE Voyage 41S (which is the same T760/UMS9620 as this
    board, and a phone with real audio) and the U30 Air's native set - across modes 0, 2, 7, 9, 28 and the
    Loopback mode 63. Every one stalls identically. The two sets are equivalent where it would matter: their
    `dsp_vbc` mode 7 is byte-identical, and `audio_structure` differs only in tuning (EQ curves, gains, an AEC
    switch), so neither is a stripped-down build.
  * Everything around it checks out. The trigger path runs in full - `ap_vbc_fifo_clear`,
    `ap_vbc_fifo_enable enable=1`, `ap_vbc_aud_dma_chn_en enable=1`, then `aud_send_cmd_no_wait cmd: 0x7
    value2: 0x1` to start the DSP. The codec end is powered: `DAC: On`, `CLK_DAC: On`, `DIG_CLK_DAC_BUF: On`,
    `CP_LDO: On` in `/sys/kernel/debug/asoc/sprdphone-sc2730/sc27xx-audio-codec/dapm/`. The SMSG interrupt
    fires and the DSP answers. Enabling dynamic debug on `snd_soc_sprd_vbc_v4`, `mcdt_hw_r2p0`,
    `sprd_dmaengine_pcm` and `audio_sipc` (`echo 'module <m> +p' > /sys/kernel/debug/dynamic_debug/control`)
    is what makes all of this visible, and is the first thing to do when picking this up.
  * Tried and made no difference: every `VBC_SYSTEM_DEV_CHANGE` / `VBC_CUSTM_DEV_CHANGE` device type,
    `VBC_DL_MUTE`/`VBC_UL_MUTE` off, `VBC_VOLUME`, the whole codec output tree (`HPL/HPR Mixer DAC… Switch`,
    `AO Mixer`, `EAR_…`, the `* Function` and `* Mute` controls), `Virt Output Switch` and `agdsp_access_en`.
    The last two are worth knowing about anyway: they appear in the Whale HAL's own string table, along with
    `VBC_SRC_BT_DAC`/`ADC`, `SYS_IIS1`/`SYS_IIS3`, `Inter PA Config` and `Codec Digital Access Disable` -
    intersecting `amixer controls` with `strings` on `audio.primary.whale.so` is a cheap way to see the whole
    vocabulary the vendor userspace uses.
  * **An AGDSP image has its addresses compiled in, and boards do not agree on them.** This is why the Moto
    G35 image takes the device down: its own device tree, pulled out of `vendor_boot.img` in the same
    firmware, puts `audio-mem` at `0xaf600000` and a **7 MiB** DSP region at `0xaf900000`, with `cmdaddr`
    `0xaf880000` and `shmaddr-dsp-vbc` `0xaf881210` - a megabyte below this board's `0xaf700000` /
    `0xafa00000` / `0xaf980000`. Written to the wrong base it runs into memory that belongs to something
    else. The same fact read the other way is reassuring: the donor image answers SIPC commands at
    `0xaf980000`, so it *is* built for this board's layout and is in the right place.
    * `CONFIG_OF_RESERVED_MEM_ADD` now reserves `0xaf600000,3M;0xaf900000,7M`, which is contiguous to
      `0xb0000000` and covers this board's layout as well, so one boot image can host either.
      `kernel/patches/audio-mem-shm-shift.patch` adds `shm_shift` for the addresses that are absolute in the
      device tree rather than derived from the region.
    * **The Moto image does not come up here, at its own addresses either.** With
      `ddr32_base=0xaf600000 dspbin_base=0xaf900000 dspbin_size=0x700000 shm_shift=0x100000` the driver
      reports `ldinfo 0xaf900000 / 7340032` and `cmdaddr is now 0xaf880000`, matching that board's device
      tree, and the device stays up instead of dying as it does at the wrong base - and the DSP still never
      answers (`failed to get command`, `audio_sblock_thread: fail to send SMSG_CMD_SBLOCK_INIT to dsp`).
      The donor image answers on the first try at this board's own addresses. Whatever the Moto image wants
      beyond a matching memory map, it is not the addresses.
    * Worth knowing if you pick that up: `audio_mem` has **three** DT parsers (whale2, sharkl2, sharkl5) and
      this board's node is `compatible = "unisoc,audio-mem-sharkl5"`. A change made in the whale2 one compiles,
      loads, accepts its module parameter and does nothing, which is a quiet way to lose an experiment.
    * Also: the boot service loads `audio_mem` at startup and the module is `[permanent]`, so trying a
      different layout means `/etc/init.d/mu300-audio disable`, reboot, load by hand, and remember to
      re-enable it afterwards.
  * **Three things took the board down** hard enough that slot B lost its boot trial and LK rolled back to
    Android. Recovery is `ANDROID_SERIAL=<the MU300> boot/android-boot-linux.sh <the image on boot_b>`, which
    verifies `boot_b` and rewrites only the 32-byte block in `misc`. The three: writing the Moto G35 AGDSP
    image; opening a **capture** stream (`arecord -D hw:1,0` with `S_NORMAL_AP01_C_CODEC` on, which died
    before its first log line); and **reading AGCP-domain MMIO while the domain was powered down**. That last
    one is the trap worth remembering - `0x56510000` (VBC), MCDT and the AGCP AHB syscon all hang the bus if
    touched with the AGDSP asleep, so a "harmless read-only peek" is not harmless. Hold a PCM open first.
* How the profile mechanism works, since the above depends on it: the parameters come from the Whale HAL on
  Android, and `vbc_profile_loading()` fetches them with `request_firmware()` under the bare names `audio_structure`,
  `dsp_vbc`, `cvs` and `dsp_smartamp`, and checks a magic - so the kernel will load them from `/lib/firmware`
  with no HAL involved, and writing 1 to the matching `… Profile Update` mixer control is what triggers it:

      struct vbc_fw_header { char magic[16]; u32 num_mode; u32 len_mode; };   /* "audio_profile" */
      /* then num_mode * len_mode bytes of packed mode data */

  The community's donor-params module ships the same three as XML for `/odm/etc/audio_params/sprd`, and those
  carry exactly what the header needs - `<dsp_vbc … num_mode="0x48" struct_size="0x6c4">` and then every field
  with its `offset`, `bits` and `val`. `tools/vbc-profile` converts one to the other.
* The F50 has no `l_agdsp` partition to take an image from (the list has `ch_sys`, `pm_sys`, `nr_modem`,
  `nr_phy` and nothing for audio). A genuine Qogirn6pro image does exist and is easy to fetch: Motorola's
  Moto G35 (UMS9620, codename *manila*) ships `QogirN6Pro_AUDCP_DSP_lit_dm.bin`, 6 MiB, in its official
  firmware - and its header reads `SharkL5_AUDCP_2024Y_VER_5003`, same lineage label as the donor's 2022 build,
  with byte-identical entry code at `+0x80`. Loading it in place of the donor took the board down hard enough
  that slot B lost its trial and LK rolled back to Android, so it is not a drop-in; the donor image is the one
  that runs.
* Things that are *not* the cause, each checked: the firmware is byte-identical to the image Android uses
  (sha256 `378ceea7…b937`, and the module verifies that same hash); the memory is genuinely reserved
  (`/sys/kernel/debug/memblock/reserved` shows `0xaf700000..0xafffffff`, 3 MiB + 6 MiB); `ldinfo` agrees at
  `0xafa00000` size `0x600000`, which is the image exactly, so `agdsp_store()` copies all of it; and the load
  order does not matter - Android writes the firmware with `sound@0` **unbound** and binds afterwards, which
  was tried here and neither rebooted nor helped. The image's header reads `SharkL5_AUDCP_2022Y_VER_2548` /
  `AUDCP.SharkL6` although this SoC is Qogirn6pro, which looks damning and is a red herring: it is the same
  image Android boots media audio with.
* `agdsp_store()` clamps every write to `ldinfo`'s size minus what it has already taken, so a firmware bigger
  than the reserved region is truncated silently and `dd` still reports success. Read the size back from
  `$BOOT/ldinfo` - `char name[32]; u32 load_phy_addr; u32 size`, so
  `od -An -tu4 -j32 -N8`. On this board it is 0xafa00000 and 6291456 bytes, which is the image exactly.
* Also worth knowing: the community Android module's `l_agdsp_a` symlink under `/dev/block/by-name` is for the
  Whale audio HAL, not the kernel - `sprd_audcp_boot` has no `request_firmware()` and no path of its own.
* A2DP over BlueZ needs none of this.

### 24b. A second board, from a clean install: where the stall actually is
Everything in 24 was measured on one hand-built unit. On 2026-09-23 the audio stack was put on a second F50 from a
clean `install.sh` (the audio kernel, its modules, the donor firmware, and profiles converted from the U30 Air's
native XML), and the stall was taken apart further. Audio still does not move; what follows is what is now known.

**Two traps on the way in, both in how the modules get loaded.**
* Running `depmod -a` with the audio modules in `/lib/modules/<release>/audio` makes them visible to `modprobe`, and
  from then on udev and the kernel's own `request_module()` load them first - without parameters. `audio_mem`
  comes up with no memory region (`memory-region 1 unavailable!(-19)`), `snd_soc_sprd_card` without
  `dummy_on_defer`, both are `[permanent]`, and the card never registers. `mu300-audio-dsp` does pass both
  parameters; it just never gets to. `/etc/modprobe.d/mu300-audio.conf` now keeps `modprobe` away from all 23
  (`install <name> /bin/false`); `mu300-audio-dsp` uses `insmod` and is not affected.
* Closing a voice stream can panic the kernel: `Asynchronous SError Interrupt` in `regmap_read <-
  check_agcp_mcdt_clock <- mcdt_dac_dma_disable <- fe_hw_free`. The MCDT driver reads an AGCP register on the way
  down, after the AGDSP domain has already dropped - the same bus hang as in 24, from inside the driver. Holding
  the domain with the `agdsp_access_en` mixer control for the length of a call avoids it; `mu300-voice` does.

**Reading the hardware without hanging it.**
* `/proc/asound/card1/vbc` dumps the DSP-side VBC registers (the DSP copies them to shared memory on request) and
  the AP-side ones with the domain held. Safe at any time, and the best single view of the stall.
* The codec's analog half and its AUDIF interface live in the PMIC and are always powered. Their registers are in
  `/sys/kernel/debug/regmap/spi4.0/registers` at `codec register - 0x3000 + 0x1000` (`CODEC_REG`, codec offset
  0x1000): `AUD_CFGA_CLK_EN` is PMIC 0x100, `AUD_CFGA_DAC_FIFO_STS` 0x144, the analog clocks 0x1068. Reading
  the whole file takes minutes over ADI; it seeks, though - lines are 15 bytes and registers 4 apart, so
  `dd bs=15 skip=$((reg / 4)) count=1` reads one.
* The digital codec (`unisoc,audio-codec-dig-agcp`, 0x56360000) and the AGCP gates at 0x56200000 are inside the
  domain: read them only while a PCM holds it, and check the stream is still RUNNING just before the read.

**What the stall is not** - each measured with a stream stalled at `hw_ptr` 160:
* not the DSP powering down: during the stall the domain is up (`0x64910544` reads 0, idle it reads 0x70700), and
  the auto-shutdown bit in `coreshutdown` is cleared by the running side itself;
* not the IIS being routed to USB (`VBC_IIS_INF_SYS_SEL` defaults to `vbc_iis_to_aon_usb`; `vbc_iis_to_pad` changes
  nothing), nor the codec being off: with the vendor route below, DAPM and the PMIC agree it is fully on;
* not the audio PLL: nothing requests it (`AUDPLL_REL_CFG` 0x64910a48 reads 0; bit 5 is `AUDIO_SEL`), but forcing
  it on (`FRC_ON`) locks it (`lock_done` at 0x64320068 bit 17) and changes nothing;
* not the AGCP clock gates (`vbc-24m`, `tmr-26m`, `dma-cp`, `iis0-2`, `src48k` are all on during a stream).

**The vendor route, from the U30 Air.** `/odm/etc/audio_route.xml` on the U30 Air (the same ums9620) says what the
HAL sets for a codec playback device: `ag_iis0_ext_sel_v2 = aud_4ad_iis0_da0` (AGCP IIS0 into the codec's DA0 -
this board had it at `pad_top`, i.e. out to pins with nothing on them), every `S_*_P_CODEC SWITCH`, 24-bit IIS
with `VBC_IIS_TX0_LRMOD_SEL = RIGHT_HIGH`, DAC0/DAC1 on IIS port 0, and the device's own mixers (`Speaker Function`
and the AO mixer). Applied in full, the codec powers up and clocks (PMIC 0x100 = 0x2, analog clocks on, DAC
enabled) - and its DAC FIFO stays empty with the write pointer at 0 (0x144 = 0x80): **nothing arrives over AUDIF
from the digital codec.** `AUDIF_EB` (0x56390000 bit 3) is only ever set by the VAD/ADC clock widget, and setting
it by hand, with its pad clock, does not change that either.

**With VBC as IIS master, the pipeline moves - slowly.** `VBC_IIS_MASTER_ENALBE = enable` with `VBC_IIS_MST_SEL_0_TYPE
= VBC_MASTER_INTERNAL` is the first setting in all of this that gets past `hw_ptr` 160: about 23000 frames go at
once, then 80-120 frames/s, i.e. one 160-frame burst about every two seconds. The DSP-side dump shows why it is
not the DA side any more: the IIS async FIFO moves (0xf88) and DAC0's FIFO reads empty (0xe7c) - DA is starved,
not stuck. What is missing is the DSP being told the AP FIFO has data: `AUD_INT_EN` (0x44) has no play-FIFO
interrupt enabled and the DSP-side DMA enable (0xeb0) is 0; neither is written by any AP driver - the firmware
sets them, and here it does not, so it falls back to polling. With the codec as master (VBC slave), nothing moves.

**Calls.** The call scene is the hostless `FE_VOICE` (device 5), which Android's HAL starts with `pcm_start()`;
`tools/pcmhost` does the same and the scene goes RUNNING during a real call. `FE_VOICE_PCM_P` (what the far end
should hear) still stops after its first burst, with the scene running, with every `AT+SSAM` mode 0-8, and in
master mode. And the call itself **ends after about 20 seconds** - which, the owner reports, it also does on this
board under stock Android: VoLTE drops a call that sends no media, and the modem never gets uplink frames from the
DSP. That is the same symptom one layer down: the DSP runs, answers commands, and moves no audio in any scene.
The one route known to work on Android is a Bluetooth headset over SCO, where the BT controller clocks the IIS.

**The DSP-side registers are not AP-addressable.** The driver's `/proc/asound/<card>/vbc` dump reads DSP-side
registers (base `0x01700000` in the driver's numbering) through the DSP, by IPC (`SND_VBC_DSP_IO`). Reading the same
offset directly from the AP at `0x56510000 + 0xe7c` - outside the 1 KiB AP VBC window - hangs the bus: the board
drops off USB and the network. To change a DSP-side register, write `"<reg> <val>"` in hex to that proc file
instead (`vbc_proc_write` -> `dsp_vbc_reg_write`, e.g. `echo 1700eb0 1`); never map it from the AP.

### 24c. What the Rongyue E5 (kanoqwq/e5-linux) did, and what of it applies here
kano's [e5-linux](https://github.com/kanoqwq/e5-linux) (MIT) runs Linux on the Rongyue E5, a UMS9621 handset with the
same AGDSP, VBC v4, MCDT and UMP9620 codec drivers. It started from this project's bring-up (its `e5-audio-dsp` is
`mu300-audio-dsp` adapted) and got further: the speaker plays (2026-09-25), the microphone records, and a cellular
call's downlink was heard on the receiver and the speaker (2026-10-02, e5-linux FINDINGS 55). Read against 24 and
24b, the differences fall in three groups.

**The board, which does not carry over.** The E5 has its own AGDSP image (`l_agdsp_a`, mmcblk0p26, header
`SharkL5_AUDCP_2023Y_VER_3029`) and a complete device tree (`memory-region` present), a speaker behind an aw87xxx,
an earpiece and microphones. Its audible call goes DSP -> codec DAC0 -> receiver / AO; this board has nothing on the
codec, so that output does not exist here.

**The kernel, which does.** Five of its 5.15 patches touch the same drivers this project builds for 5.4, and the
symptoms they fix are the ones in 24:
* `0013` period events from an hrtimer. The E5 measured what 24 measured - both `sprd_dma` lines at 0 for a whole
  stream, with or without the DSP - and concluded that nothing will ever call `snd_pcm_period_elapsed()`: the
  completion interrupt is the DSP's or nobody's. Its answer is the one Android's HAL gets by opening with
  `PCM_NOIRQ`: program the DMA without interrupts and tick the period from a timer.
  `kernel/patches/audio-pcm-period-timer.patch`.
* `0016` the position read only while `agdsp_can_access()` says the AGCP domain is reachable - the bus hang of 24,
  hit on the E5 after six idle hours. `audio-pcm-pointer-agcp-access.patch`.
* `0017`, `0019`, `0020` the DSP front ends limited to S16_LE where the DSP writes S16 whatever was asked, and to
  interleaved access on every MCDT front end. `audio-fe-dai-formats.patch`.
`kernel/build-audio.sh` applies all three; the 23 modules build with them (2026-10-11). Its other patches are E5
board matters (aw87xxx, a headset IMPD oops, the agdsp_pd module order of its tree, which is built in here).

Its notes also contradict one line of 24: there `agdsp_access_en` "changed nothing"; on the E5 it is the control
that turned "the DMA runs one burst and stops" into "the VBC FIFO drains" (e5-linux FINDINGS 24.2), with
`VBC DAC0 DG Set` non-zero (Linux leaves it 0, which is digital silence). With the period timer both need
re-measuring here before either reading is trusted.

**The call sequence, which does.** What the E5 changed between "both PCMs RUNNING, silence" and "heard" (`402fde1`,
`8e9b8a4`, `2c726fc`), against what `mu300-voice` did:

| | mu300-voice until now | e5-linux |
|---|---|---|
| call scene | `FE_VOICE` playback only, 16 kHz | `FE_ST_VOICE` playback **and** capture, 8 kHz mono, both prepared before either starts |
| profile select | `(mode << 24) \| (0x5e << 16)`, through amixer | `(mode << 24) \| (mode << 16) \| 5` (param id = mode, low byte the voice DAI), raw, before and after the start |
| voice volume | not set | `VBC_VOLUME` = volume + 1, raw (the control declares max -1, amixer clamps) |
| downlink mute | not touched | `VBC_DL_MUTE` enable during routing, then `VBC DAC1 DSP MDG` 0,1024 and `VBC_DL_MUTE` disable after the start - the change that made it audible |
| bandwidth | none | `/dev/audio_pipe_voice` command 0 channel 2 gives NB/WB/SWB/FB; the profile follows it |

Two of these are bugs here on their own: amixer clamps every profile select from mode 16 up - the Bluetooth modes
(BTHS, 28 and up) included - to `0x0fffffff`, and a capture-less scene leaves the DSP without an uplink, which is
the VoLTE ~20 s drop of 24b. `mu300-voice audio start` now does the E5's sequence; the undo log puts every control
back on `audio stop`.

**Bluetooth, which is the output this board has.** kano reports that the F50 under Android, with the AGDSP image of
a ZTE Voyage 41S (the donor of 24), connects a Bluetooth headset and carries calls on it. That fits: this board's
PSKey has `g_sys_sco_transmit_mode = 0`, and on the E5's identical controller mode 0 sends SCO audio over the
controller's PCM pins into VBC IIS3, not over HCI (e5-linux FINDINGS 58-59: no HCI SCO RX, nonzero samples on the
IIS3 capture once the pin matrix was switched). The vendor route (`audio_route.xml`, `bt_sco` and `btsco_p/_c`)
is `SYS_IIS0 = vbc_iis3`, `S_VOICE_P_BT` / `S_VOICE_C_BT`, `VBC_SRC_BT_DAC/ADC`, and the E5 found the BT rate must
be set again after the scene is RUNNING. Two of its findings matter here: on mainline `SYS_IIS0` was a no-op without
the pin controller (the 5.4 kernel has `pinctrl-sprd-qogirn6pro`), and BlueZ's own SCO path stays silent with this
PSKey, so the AP must not try to carry SCO audio itself.

What a call on a headset needs from the AP is therefore only the links: the DSP scene (`mu300-voice audio start bt`)
and an HFP audio gateway holding the service level connection and the SCO link. BlueZ has no AG of its own (oFono
would want the modem), so `tools/hfp` (`mu300-hfp`) is a minimal one on raw kernel sockets: it connects to the paired
headset, answers the AT setup, opens CVSD SCO when told, and turns the headset's buttons into `ATA` / `AT+CHUP`.
`mu300-voice watch` follows `AT+CLCC` and drives both. The AGDSP image stays the user's to supply:
`mu300-audio-dsp install FILE` checks size and the `AUDCP` header and records the sha256 on the device.

Not measured yet, for want of the firmware on any test board: whether the 41S image runs the BT call scene under
Linux, and whether the period timer moves `FE_VOICE_PCM_P` / `FE_VOICE_C`.

2026-10-13, against v2026.10.23: the seven audio patches apply to the pristine realme tree in `build-audio.sh`'s
order and all 23 modules build against the 5.4 tree (`sprd-dmaengine-pcm` with its `period_timer` parameter); they
were not loaded on a board - the released 5.4 kernel has no audio modules, and no test board has the firmware. On
F50-B the userspace was run on the released 5.4 and on 7.2.10: without the drivers `mu300-voice` says that this
kernel has no call audio (it used to say "run mu300-audio-dsp load", which cannot work there), `mu300-hfp` refuses
an address that is not bonded, and nothing is left running. The call itself, on a headset or through the taps, is
still unmeasured.

### 24d. A call carries audio: the voice port had no clock
Measured on F50-C on 2026-10-17 (OpenWrt v2026.10.17.3 on the 5.4 kernel, the 5.4 audio stack now published as
[mu300-audio](https://github.com/dikeckaan/mu300-audio), the 41S DSP image of 24c). Six calls went to the owner's
own phone, and he reported what he heard:

| call | what was sent | what he heard |
|---|---|---|
| 1, kernel 6.18 (no DSP) | DTMF from the modem (`AT+EVTS` start and stop), `AT+SPMSTONE` / `AT+STONE` tones, `AT+SDTMF` | "some broken sounds, nothing meaningful" |
| 2, kernel 5.4 + DSP | music into `FE_ST_VOICE_PCM_P` at 16 kHz, then `AT+STONE` | silence |
| 3, kernel 5.4 + DSP, IIS port 1 clocked | Ode to Joy (8 kHz, 32 s) into `FE_ST_VOICE_PCM_P` | music "from the first second" |
| 4, the same through `mu300-voice` | melody, then 6 s recorded from `FE_ST_VOICE_C` and played back | melody fine; his own voice came back unrecognisable ("slow motion, muffled") |
| 5, as 4 with `VBC_SRC_DAC1/ADC2` = 16000 and 16 kHz taps | melody, then the echo | melody fine, then only crackle |
| 6, nothing played; he counted aloud | four 8 s captures (clock / tap rate varied) | crackle the whole call |

**The modem log is what found it.** The CP writes its own log to the `slog_nr` spool channel, which
`modem-log-drain` throws away. `AT+ARMLOG=1` turns it on. The records hold the format string followed by the
arguments as little-endian u32s, so `strings` alone gives the sequence and a few lines of Python give the
values. In call 2 the modem did everything right. At alerting (`APP_MN_PROGRESS_IND`) it logged `AUDCTL: Start
codec, mode:3`, `init_agdsp_sharedmem`, `agdsp access, check status OK`, enabled MCDT channel 6 in both
directions and posted its command to the DSP. From then on it wrote 200 bytes of downlink into MCDT every 20 ms.
**Every `mcdt_recv read_cnt` was 0**: the DSP returned no uplink frame in the whole call. The modem's own MCDT
register dumps show channel 6's FIFO filling up (`0x565000fc` climbing to 0x200) and never draining. So the
handover from the modem to the DSP works, and the DSP is what stands still. The note in 24b that "the modem never
hands the call to the DSP" was an inference from the silent `/dev/audio_pipe_voice`, and it was wrong.

**The DSP's call scene runs on VBC IIS port 1, and nothing clocks that port.** The voice DAC1/ADC2 muxes sit on
`VBC_IIS_PORT_IIS1`. `VBC_IIS_MST_SEL_0_TYPE`, the setting tried before (24b), was already
`VBC_MASTER_INTERNAL` at boot, and it only covers port 0. That is why it made `FE_ST_NORMAL_AP01` run in real
time and left the call scene where it was. Bench test with the scene up and no call: `FE_ST_VOICE_C` stays at
`hw_ptr` 0 until `VBC_IIS_MASTER_ENALBE = enable` **and** `VBC_IIS_MST_SEL_1_TYPE = VBC_MASTER_INTERNAL` are set.
Then 2 s of capture comes back in 2 s. The checks:

* `MST_SEL_2` or `MST_SEL_3` instead of 1: nothing moves.
* `MST_SEL_1` without the master enable: nothing moves.

`FE_ST_VOICE_PCM_P` still sits at its first buffer without a call. It moves once the modem feeds the scene. With
both settings, call 3's modem log reads `read_cnt=200` on every 20 ms frame, and the playback tap took 32 s for
32 s of audio.

**The uplink works; the downlink tap is still wrong.** Call 4 used `mu300-voice` itself (`audio start dsp`, `tone`,
one round of `echo`). The melody arrived. The capture tap `FE_ST_VOICE_C` (`VBC_DSP_VOICE_CAPTURE_TYPE` downlink)
does carry the far end, but only half of it. Call 6 measured it with the owner counting aloud:

| capture | port clock (`VBC_SRC_DAC1/ADC2`) | frames per second, in the call | content |
|---|---|---|---|
| 8 kHz | 0 (default) | 4000 (48000 frames in 12 s) | his voice, F0 115-145 Hz (right pitch) |
| 16 kHz | 0 | 8000 (96320 in 12 s) | speech, little of it |
| 16 kHz | 16000 | 16000 | all zero |
| 8 kHz | 16000 | 8000 | all zero |

At the default clock the pitch is right, so nothing is stretched. Instead, the 8 kHz capture shows a hard
discontinuity every 160 samples, i.e. at every 20 ms frame boundary. The AP receives one 20 ms frame per 40 ms,
and the frames it gets do not join up: every other downlink frame is lost. Echoed back, that is what he heard
as broken "slow motion" speech. The modem is not the cause: in call 3 it handed over and took back a frame every
20 ms (`read_cnt=200`).

* Without a call, the same tap runs at the clock's rate. That is 8000 frames/s at the default, and 16000 with
  `VBC_SRC_*` = 16000, which therefore sets the internal master's rate.
* With `VBC_SRC_*` = 16000 in a call, the tap paces correctly but carries zeros. The far end then hears
  crackle, so that setting is not the fix.

Not solved here: why the DSP writes the downlink tap at half the frame rate. Next things to try:

* the capture period / buffer sizes (only 160/960 and 320/1920 were used);
* `FE_ST_CAPTURE_DSP` or `FE_ST_DUMP` instead of `FE_ST_VOICE_C`;
* the scene at 16 kHz with the default clock.

**With nothing playing into `FE_ST_VOICE_PCM_P`, the far end hears crackle.** In `UPLINK_ONLY` mode with no AP
stream, the DSP sends whatever is in its buffer, not silence. A bridge has to keep that stream fed with silence for
the whole call; `mu300-voice` only writes while `tone` or `echo` runs.

**What `mu300-voice` does now.** The `dsp` route calls `dsp_clock`, which sets the master enable and the
`MST_SEL_0/1` internal clock through the undo log. `audio start` sets it again once the scene is RUNNING, and
`audio stop` puts the VBC back to slave mode. The `bt` route leaves it alone, because there the headset
controller's PCM clocks IIS3.

Other things learned along the way:

* **Network DTMF is not a tone channel.** `AT+EVTS=1,<d>` / `AT+EVTS=0,<d>` (what the RIL sends), `AT+VTS`, and
  `AT+VTD` (default 1) all work during a VoLTE call and return OK. They travel as RTP events, though, and what
  reaches the far end is not a recognisable tune. As keys they do what they are for, **but only while the audio DSP
  is in the call**: `AT+VTS="<key>"`, one per key. Without the scene the modem takes them all the same and sends
  nothing. Measured against a 4G voice module at the far end that reports each DTMF key it receives on its serial
  port (F50, OpenWrt, 6.18, 2026-10-18, by Gardelll): on five answered voice calls with the scene down (and a video
  call on 6.18.57 with no audio driver loaded) every `AT+VTS` sent - `123` on one, `*#0123456789` or the start of
  it on the others - returned OK and the module reported none; on the next call, the scene started first
  (FE_ST_VOICE RUNNING), it reported all of `*#0123456789` in order, and the same with `mu300-voice dtmf`. The
  modem hands its tone generator to the DSP (next point); the RTP events evidently come from the DSP's side of the
  call as well. `mu300-voice dtmf KEYS` sends them, one `AT+VTS` per key, and refuses unless FE_ST_VOICE runs (in
  either direction, whoever started it: `audio start`, or another program that runs the scene while it sends keys).
* **`AT+STONE`, `AT+SPMSTONE`, `AT+SDTMF` and `AT+SPVLOOP` all return OK**, outside a call as well. The modem
  hands its tone generator to the DSP (`CP_CMDQ_START_TONE`), so on 6.18 these do nothing. None of them gave a
  heard tone on 5.4 before the clock fix either.
* **The modem log costs nothing to keep open.** Stop `modem-log-drain` and read `/dev/slog_nr` in a loop: one
  `dd` returns at every channel close. `AT+ARMLOG=0` turns the log off again.
* An earlier program of the owner's used `FE_ST_VOICE_PCM_P` at 16 kHz with period 640 x2. That is the MU5358's vendor
  scene, and on that board the HAL's own call scene clocks the port. Here 8 kHz with 160 / 960 is what was heard.
  16 kHz was only tried without the clock (call 2).

### 24e. Both directions at the right speed: the downlink from the VBC dump, the uplink at 16 kHz
Measured on F50-C on 2026-10-17 (OpenWrt v2026.10.17.4 on the 5.4 kernel, the 5.4 audio stack
([mu300-audio](https://github.com/dikeckaan/mu300-audio)), the 41S DSP image), with the IIS1 clock of 24d. Most
calls were left ringing and hung up before the answer: the network's early-media ringback (425 Hz, one second on,
about four off) is a reference tone that needs nobody on the other end.
A few calls were answered by the owner, who counted aloud and then heard his recording played back.

**`FE_ST_VOICE_C` stays at half rate whatever is changed.** The tap runs at 8000 frames/s until the modem starts the
codec, two to four seconds into the dialling, and then at 4070-4090 frames/s for the rest of the call. Each 160-sample
frame that does arrive holds the ringback at exactly 425 Hz, so nothing is stretched: every other 20 ms frame is
missing. The mean step across a frame boundary is five to six times the step inside a frame. These changed nothing:

* the call scene (`FE_ST_VOICE`) at 16 kHz instead of 8 kHz;
* `VBC_SRC_DAC1` and `VBC_SRC_ADC2` = 16000, set before the scene starts or after it, together or `DAC1` alone;
* two channels instead of one (without a call, the tap then moves 4000 frames/s, which is the same 8000 samples/s).

The DSP's bandwidth messages on `/dev/audio_pipe_voice` said band 0 (NB) in every one of these calls.

**The VBC dump of DAC1 carries the whole downlink.** `FE_ST_DUMP`, with `S_VBC_DUMP SWITCH` on and `VBC_DUMP_POS` =
`DUMP_POS_DAC1_E`, records what DAC1 sends to the IIS1 port. That is the downlink after the DSP has finished with it.
It runs at the VBC's own rate whatever hw_params asks: 47,990-48,000 frames/s on two equal channels. Mono, 8 kHz and
16 kHz requests open as well, and still deliver about 48,000 frames/s. In an unanswered call the ringback came through
it at 425.0 Hz with no seam (largest step against median step: 2). Above 4 kHz there is nothing (-63 dB), which is
what an NB call gives. Decimated to 8 kHz, the owner's counting was continuous (seam ratio 1.15) at 8000 frames/s.
`FE_ST_CAPTURE_DSP` refuses `PREPARE` (EINVAL) in this scene. Without the dump switch, so does `FE_ST_DUMP`.

**`FE_ST_VOICE_PCM_P` is consumed at 16 kHz.** The uplink tap was played a 1 kHz tone, and `VBC_DSP_VOICE_CAPTURE_TYPE`
was set to `VOICE_CAPTURE_UPLINK` so that `FE_ST_VOICE_C` showed what the DSP sends up. Opened at 8 kHz, the tone came
back at 2000 Hz. Opened at 16 kHz with 320-frame periods, it came back at 1000 Hz. The owner heard the 8 kHz version
of his own voice "like a child's" and the 16 kHz one at the right pitch. The melody of 24d played at 8 kHz was
therefore an octave high and twice as fast. It was still recognisable as music, which is all that test checked.

**Restarting a voice stream panics the kernel.** A PCM that underruns or overruns and is then prepared and started
again on the same open runs `sprd_pcm_trigger` -> `vchan_tx_submit` with the DMA descriptor `hw_params` prepared once.
The second submit corrupts the virt-dma list: `list_del corruption` in `__list_del_entry_valid`, a kernel panic, and
the board hung off USB until it was power-cycled. This was hit once, by a client that recovered from an xrun with
PREPARE + START. aplay and arecord do the same on an underrun (EPIPE). Clients of these streams must not stop them:
`stop_threshold` = the boundary, and for playback `silence_size` = the boundary, so that the kernel fills a late write
with silence. A stream that does stop has to be closed and opened again. The driver could re-prepare the descriptor
in `prepare`; that is a fix for the 5.4 audio patches (mu300-audio).

**What uses this now.** For the dsp route, `mu300-voice audio start` switches the dump on at `DUMP_POS_DAC1_E` through
its undo log (`MU300_VOICE_DUMP_TAP=0` leaves it off). `tone` plays at 16 kHz (`MU300_VOICE_PLAY_RATE`). `echo`
records the dump and plays it back through alsa-lib's `plug`. That echo path has not yet been run in a call. A program
that bridges the call through these taps reads the dump and decimates it to 8 kHz behind a 47-tap low-pass. It
writes the uplink at 16 kHz through a polyphase interpolator, and feeds silence for as long as the stream is open.

### 188. Call audio on the mainline kernels: the 5.4 stack ported to 6.18 and 7.2
The Unisoc audio stack of 24-24e ran only on the vendor 5.4 kernel. It is now built for 6.18.57 and 7.2.11 with
every release (`upstream/modules/sprd_audio`), and `mu300-audio-dsp` and `mu300-voice` work on those kernels.
F50-B was measured on 7.2.11 (Ubuntu 24.04) on 2026-10-17, with the 41S DSP image of 24c (sha256 `378ceea7…b937`).
The image is still the user's to supply; this repository has no copy of it.

**What was ported, and from where.** The sources are our own 5.4 drivers: the realme `unisoc-5.4` tree that
`kernel/build-audio.sh` builds, with the same seven patches. These are the drivers measured in 24-24e. Their mixer
controls, device numbers and scene behaviour are what `mu300-voice` relies on.

The Rongyue E5's 6.18 port (Enceka/linux-lts-e5 `0015e503b`, `9c5909e2c`, `03e89ea23`, `8048e353a`) comes from
Unisoc's 5.15 tree for the UMS9621. Two parts of it do not fit here. Its `agdsp_pd` replaces `agdsp_access`, and the
F50's device tree describes `unisoc,agdsp-access`. Its VBC driver is 2200 lines newer. What it was used for:

* the vendor AGCP DMA driver (`dma/sprd-dma.c`). This is the E5's file: the 5.15 driver with `slave_id` passed
  through `peripheral_config`. It differs from our 5.4 driver in about 30 lines;
* the `ioremap()` of memory without pages (`8048e353a`);
* how each 5.4-to-6.x API change looks in this code: DAI probe and `compress_new` moved into the ops, and `aif_name`
  became a per-DAI table;
* the GPIO compatibility helpers.

The stack is 19 modules plus `sprd-dma`. `saudio`, `sprd_dai`, `vaudio` and `ucp1301` are left out because no node of
`sound@0` uses them.

The API changes between 5.4 and 6.18, all in `mu300_audio_compat.h` or at the call site:

* PCM and compress ops became component callbacks that take the component.
* `pcm_new`/`pcm_free` became `pcm_construct`/`pcm_destruct`.
* `rtd->cpu_dai` became `snd_soc_rtd_to_cpu()`.
* `dpcm_playback`/`dpcm_capture` became `playback_only`/`capture_only`.
* `snd_soc_of_parse_daifmt()` became `snd_soc_daifmt_parse_format()` plus the clock-provider call.
* `dma_slave_config.slave_id` is gone. The request id now goes through `peripheral_config`, via a field of
  `sprd_dma_cfg`.
* Platform drivers' `remove()` returns void.
* `class_create()` takes one argument.
* The syscore hook is gone; it was a no-op.
* `hrtimer_setup()` replaces `hrtimer_init()`.
* `sched_set_fifo()` replaces `sched_setscheduler()`, which is not exported.
* The wakeup-source calls changed.
* `regulator_register()` takes the device.
* The legacy GPIO calls changed.

7.2 added more changes:

* The DAPM context is opaque: `snd_soc_component_to_dapm()`, `snd_soc_card_to_dapm()`, `snd_soc_dapm_to_card()`.
* `pcm_construct` is called `pcm_new` again.
* `strncpy()` is gone.

**The kernel.**

* `patches/0022` adds `CONFIG_OF_RESERVED_MEM_ADD`, the 6.18 counterpart of the 5.4 patch. It reserves
  `0xaf600000,3M;0xaf900000,7M`, as 5.4 does, with `memblock_reserve()`, so the pages stay.
* The fragment sets:
  * `SND_SOC=m`;
  * `SND_SOC_SPRD=m`, only for its `select SND_SOC_COMPRESS`, which has no prompt. Its own platform driver matches
    no vendor node;
  * `SND_DYNAMIC_MINORS`, because the card has PCM devices up to 53;
  * `DMADEVICES`.
* `virt-dma` is not a symbol one can enable, so `sprd-dma` compiles the kernel's own `virt-dma.c` into itself.
  `build-modules.sh` copies it from the tree it builds against.
* `all-modules.exclude` gains `dir sound/soc`. Otherwise `SND_SOC=m` opens `SND_SIMPLE_CARD`, `SND_DESIGNWARE_I2S`
  and other options whose names do not start with `SND_SOC`.
* No audio module carries a `MODULE_DEVICE_TABLE`, so udev cannot load them. The trap of 24b (modules loaded without
  parameters, then `[permanent]`) cannot happen. `mu300-audio-dsp` inserts them in order, after
  `modprobe snd-soc-core snd-compress`. Neither module is on the on-demand guard's list.

**Where the modules are.** On Ubuntu they are in `/lib/modules/<release>/extra`; on OpenWrt they sit flat in the
release directory. `mu300-audio-dsp` looks in `audio/` (the private 5.4 stack), then `extra/`, then the release
directory itself. `mu300-voice` used to refuse every non-5.4 kernel; it now refuses only a kernel with no audio
drivers.

At boot, `mu300-audio` runs on mainline when an AGDSP image is installed (`/lib/firmware/agdsp.bin`); without one,
nothing loads. On 5.4 it runs when the `audio/` of [mu300-audio](https://github.com/dikeckaan/mu300-audio) exists,
as before.

**Faults 5.4 never showed, or hid.** The first two each oopsed F50-B at the first PCM open and rebooted it.

* *The DSP's DDR was mapped as Device memory.* `audio_mem_vmap()` maps it `pgprot_noncached`, and
  `aud_send_cmd()` → `audio_cmd_copy()` memcpy()s the 620-byte scene command into it. The 7.x `memcpy` ends with an
  overlapping unaligned store: `FSC = 0x21: alignment fault` in `__pi_memcpy_generic`. The DDR is now mapped
  Normal non-cacheable (write-combine). That is still uncached for the DSP, and it allows unaligned access. The IRAM
  has no pages and stays a Device `ioremap()`, because a speculative read into the AGCP while it is asleep would hang
  the bus (24).
* *No headset, and a NULL dereference.* The codec calls `headset_set_audio_state()` at every stream start, and on
  mainline the headset does not probe (`get gpio for 'aud_int_all' failed`): `sprd_hdst` is NULL. The board has no
  jack, so the function now returns when there is no headset; `sprd_headset_remove()` does the same.

* *A power-up wait that held a CPU for seconds.* `agdsp_access_enable()` polled the PMU up to 1,000,000 times
  with its spinlock held, which took about 6 s. On 6.18.57 after a warm reboot the domain did not come up, and the
  card's bind calls it once for every codec register it reads. pstore holds 41 timeouts in a row, then the
  soft-lockup detector (`softlockup_panic=1`) panicked the kernel inside `__delay`. The wait now runs with the lock
  released: `regmap_read_poll_timeout()` with `usleep_range` for up to 200 ms where the caller may sleep, and at most
  2 ms of spinning where it may not (a trigger). A timeout returns -EBUSY to the caller and never hangs the kernel.
  A caller that arrives while another is waiting waits as well, and counts are given back on failure.
* *The DSP restarted only in a powered domain.* After a warm reboot the AGDSP still runs the previous kernel's
  image. `start` pulses its resets, and with the domain asleep the pulse does not reach it. Every step reports
  success, and the old image never answers the new kernel: `aud_smsg_send, channel 0 not opened, ipc state : 2,
  dsp_ready 0`. Holding the domain (`agdsp_access_en`) and starting again made it answer at once. `mu300-audio-dsp
  start` now holds the domain across the firmware write and the start. This is the "start is once per boot" of 24:
  a second start was the same reset into a sleeping domain. Since the change: 6.18.57 and 7.2.11 on F50-B, and
  7.2.11 on F50-C (all after a warm reboot from a kernel whose DSP was running) give 0 power-up timeouts, and the DSP
  answers.
* *A WARNING at every boot.* `alsactl` restores every control when the card appears, and writing 0 to the codec's
  bias control disabled a regulator that nobody had enabled. The control now only acts on a change.

**The restart that panicked 5.4 (24e) is fixed in the driver.** `sprd_pcm_trigger()` submitted the descriptor that
`hw_params` had prepared on every START, RESUME and PAUSE_RELEASE. A linked-list audio transfer never completes, so
virt-dma still held the descriptor, and the second submit corrupted the channel's list. Now:

* every descriptor is submitted once;
* a paused or suspended stream is resumed (`dmaengine_resume()`);
* `prepare()` of a stream that has run stops its channels with `dmaengine_terminate_sync()`, which frees every
  descriptor virt-dma holds, then builds new ones from the configuration still in `dma_cfg_array`
  (`sprd_pcm_prep_desc()`).

Measured on FE_ST_DUMP with a reader that stalls 0.8 s every few seconds: 9 overruns, each followed by arecord's
PREPARE + START on the same open; 9 times `new DMA descriptors`; 12 s of capture delivered; no oops. On 5.4 the first
of these panicked the kernel.

**Hardened before release (a security review of the port).** The stack is vendor code, and parts of it take
values from userspace without checking them.

* *Who can reach what.* The mixer and PCM nodes (`/dev/snd/*`) are `root:audio 0660` on both images (udev on
  Ubuntu, procd's `hotplug.json` on OpenWrt). On Ubuntu the default user `ubuntu` is in `audio`, and so is the
  logged-in user through logind's ACL. The tuning nodes (`/dev/vbc_turning*`), the DSP pipes (`/dev/audio_pipe_*`)
  and the dumps (`/dev/audio_dsp_*`) have no rule, so they are `root 0600`; `android-vendor/ueventd-perms.sh` sets
  the same. The mixer controls are therefore what a non-root user can reach.
* *Every control write is range-checked by the kernel.* `CONFIG_SND_CTL_INPUT_VALIDATION=y`: the ALSA core refuses
  a value outside the control's declared range or item count before the driver sees it. The vendor checks did not
  always hold. About 40 enum puts compared `value.integer.value[0]` (a `long`) against the item count and then
  indexed with `value.enumerated.item[0]` (an `unsigned int` in the same union). A second item that made the `long`
  negative passed the check with any first item: an out-of-bounds read of the text tables, and an out-of-range
  write into the DSP's settings. Each now checks the value it uses.
* For that, two declared maxima had to become real. `MAX_32_BIT` (`0xffffffff`, held as -1 in a control's `int`
  max) declared every 32-bit control's range as below its minimum; it is now `0x7fffffff`. The profile selects
  declared `0x0fffffff`, while modes run to 66 (`mode << 24`). That is also why amixer clamped every mode from 16
  up (24c); it is now `0x7fffffff`.
* *Profiles.* A profile is a blob: header, then `num_mode` × `len_mode` bytes. It arrives from `/lib/firmware` or
  through `/dev/vbc_turningN`, and its header was trusted:
  * it was read from a buffer that could be shorter than the header;
  * the data buffer of an earlier, smaller profile was kept, and a larger one was copied into it (a heap overflow);
  * a "Profile Select" then read mode N of the new header out of the old buffer (an out-of-bounds read);
  * the tuning node changed the profile without the lock the apply path takes, and its read returned a whole
    `vmalloc` buffer that was only partly filled.
  `vbc_profile_store()` now checks the size, the magic and the product (at most 256 modes, 4 MiB), and allocates
  exactly what the header says. The apply path checks the mode against the profile that is loaded, the tuning node
  works under the lock with a zeroed, bounded buffer, and a rejected blob changes nothing.
* *Compressed offload is off.* `sprd-compr-2stage-dma` has to be there for the card to register (link
  `FE_OFFLOAD`), but nothing here uses it, and its copy and `set_params` paths are unaudited vendor code. Its open
  returns -EPERM unless the module is loaded with `allow_offload=1`.

**Measured without a call: F50-B on 7.2.11 and 6.18.57, F50-C on 7.2.11 (OpenWrt).**

* `mu300-audio-dsp load`: 19/19 modules, two DMA controllers with 60 channels. `sprdphone-sc2730` registers with
  FE_ST_VOICE_PCM_P at device 53, FE_ST_DUMP at 16 and FE_ST_VOICE at 5, the numbers of 5.4.
* `mu300-audio-dsp start`: `aud_send_cmd out,cmd =4 … repeat_count=1` and `cmd =5`; status `core=0 sys=0`. The DSP
  runs and answers.
* `mu300-voice audio start dsp` (no call): the hostless scene is RUNNING.
  * FE_ST_VOICE_C at 8 kHz takes 4.13 s for 4 s (IIS1 on the internal clock, 24d).
  * FE_ST_DUMP at 48 kHz stereo takes 4.01 s for 4 s. Opened at 16 kHz mono, it delivers about 46,000 frames/s
    (24e).
* `audio stop` restores every control, with no oops.
* 6.18.57 and F50-C give the same figures within 0.1 s: FE_ST_VOICE_C 4.14 s, FE_ST_DUMP 4.02-4.14 s, and every
  forced overrun re-armed (9, 10 and 3).

**A call on mainline.** F50-C, 7.2.11 (OpenWrt), 2026-10-17 21:53, to the owner's phone, through
`mu300-voice audio start dsp`:

* The ringback in FE_ST_DUMP is exactly 425 Hz, so the capture rate is right.
* The melody went into FE_ST_VOICE_PCM_P at 16 kHz with 320/1920 periods. The owner heard it as good, so the uplink
  works on mainline.
* While he counted, 10 s of FE_ST_DUMP were recorded: L == R on every frame, and the voiced segments have an F0 of
  140 Hz (autocorrelation 0.72), which is his voice. So the downlink works too.
* What he did not hear was the echo of it: "slow motion, crackly, unintelligible". That was `mu300-voice`'s echo,
  not the kernel. It played the 48 kHz stereo file through `plughw:<card>,53`, and plug opened the tap at
  48000 Hz / 2 channels (read back from its `hw_params`: the tap takes any rate it is offered). The DSP consumes it
  as 16 kHz mono, so each sample came back doubled, at a third of the speed. 5.4 has the same bug: 24e notes that
  the echo had never run in a call.
* The echo now plays through `mu300_uplink`: an alsa-lib configuration of its own that includes the system's
  `alsa.conf` and pins the plug's slave to the tap's rate in mono (`rate 16000 channels 1`), with 20 ms periods. On
  F50-B the tap then reads back 16000 Hz / 1 channel.

* The verification call (F50-C, 7.2.11, 22:41, answered) ran the melody and then `mu300-voice echo 10` through
  `mu300_uplink`. The owner: "I heard my voice and the music played." Both directions of a cellular call now work on
  the mainline kernel, through the AP taps, the same way as on 5.4.

Not measured on mainline: a call to a Bluetooth headset (the `bt` route of 24c), and a program that bridges the
voice taps for a whole call (it reads the dump and writes the uplink at 16 kHz itself, so it needs no change).

**Two faults after a killed test call (F50-C, 7.2.11, 2026-10-18), and their fixes.** The owner stopped a running
`mu300-voice call` with a TERM. The next `call` failed with `aplay: audio open error: Resource busy`, for the melody
and for the echo. After that, the first FE_ST_DUMP open failed with EIO, and the open after it worked. Both were
reproduced on F50-B (Ubuntu 24.04, 7.2.11, the release's audio stack, the 41S image) without a call: the hostless
scene, `demo`, `echo`, and plain opens of the PCMs.

* *The player outlived the script.* `mu300-voice` ran aplay and arecord in the foreground, and the melody's aplay
  in a `$(...)`. A TERM ended the shell and nothing else. A shell also runs its trap only after the foreground command
  returns, so a trap alone would not have helped. On F50-B: `echo 30` was killed during its arecord, and the arecord
  kept FE_ST_DUMP (`pcmC1D16c`) open to the end of its 30 s. A second `echo` then failed with `audio open error:
  Device or resource busy`. `echo 2` was killed during the echo's `aplay -D mu300_uplink`, and that aplay was still
  holding `pcmC1D53p` a minute later. That is the owner's orphan; without a call the tap does not move, so it waits.
  The same happened with INT.
  Now every aplay/arecord is a child. The script starts it in the background and waits for it. TERM, INT, HUP and exit
  end each child (TERM, then KILL after 3 s) and wait until it has gone, so its PCM is closed. A scene that is still
  starting is stopped and its controls are put back. A scene that has started belongs to the call and stays (`audio
  stop`, `hangup`), as before. On F50-B, TERM, INT (sent as a terminal sends it) and HUP each ended the script in
  0.1-0.2 s with nothing left on either PCM.
  When an open reports busy, the script says who holds the node (from `/proc/*/fd`; OpenWrt's busybox has no
  `fuser`). If the holder is an aplay or arecord playing or recording one of the script's own files in
  `/run/mu300-voice`, it is a leftover of an earlier run: the script ends it and tries once more. Anything else is
  only reported. With the old script's one-minute-old orphan on `pcmC1D53p`, the new `echo` printed
  `/dev/snd/pcmC1D53p is held by pid … (aplay), left over from an earlier mu300-voice: ending it` and went on.
  Ending a player is a close of its PCM. Nothing here prepares and starts a stream again after it stopped, which
  panics 5.4 (24e).
* *DSP replies nobody waited for.* On the VBC control channel, the DSP's replies are read in order.
  FE_ST_VOICE_PCM_P's trigger and its shutdown send a KCTL_SET (cmd 9, `SND_KCTL_TYPE_VOICE_MIX_UL`) with
  `aud_send_cmd_no_wait_param()`. The DSP answers each one anyway, so every play into the uplink tap leaves two replies
  in the channel's cache. A sender whose wait is interrupted leaves its reply too. The next KCTL_SET that does wait
  drains them, because they carry its own command number. A STARTUP (cmd 4) does not:
  `aud_recv_cmd()` failed on the first reply for another command. The drain before the send stopped there, and each
  of the wait's 4 tries read one more. With five queued, the open failed:
  `aud_recv_cmd, Haven't got right cmd(0x4), got cmd(0x9)` five times, then `aud_send_cmd: failed to get
  command(4), ret=-5`, `dsp_startup: … vbc_dsp_func_startup return error`, and `ASoC error (-5) … BE_DAI_ID_DUMP`.
  This is the same log as F50-C's. It took no kill. On F50-B, after `audio start dsp`, one play into
  `hw:1,53` before a FE_ST_DUMP open gave `cmd =4 … repeat_count=4`, a pass by one try. Three plays gave the EIO
  every time. `demo` reaches the state by itself: without a call each of the melody's three framings fails, which
  makes six plays. The next open worked because the failed one had read five replies. The answer to the failed
  STARTUP is then left in the cache too, and a later KCTL_SET read `got cmd(0x4)`.
  * Fix in the driver (`upstream/modules/sprd_audio/.../audio-sipc.c`): a reply for another command is dropped
    (`dropped a stale reply` in dmesg), and the wait goes on for the right one within the same timeout. A deadline
    replaces the fresh 3 s of each try. With timeout 0 (the drain), it reads until the cache is empty, at most 256
    replies. The 5.4 driver has the same function line for line. It gets the same change as
    `kernel/patches/audio-sipc-stale-reply.patch`, the eighth patch of `build-audio.sh`, and in
    [mu300-audio](https://github.com/dikeckaan/mu300-audio)'s prebuilt `audio_sipc.ko`.
  * Fix in the script: an open that fails with `audio open error: Input/output error` is tried once more, after
    0.5 s, as a new open. That covers a kernel without the fix. On F50-B with the release driver: `demo 2` printed
    `/dev/snd/pcmC1D16c: the DSP refused the open (EIO), trying once more`, and the second open went through
    (`repeat_count=1`) into the echo loop. The old script stopped at `capture failed`.
  * Measured for the driver change: `tests/test_voice_cleanup.py` compiles `aud_recv_cmd()` against a fake message
    cache. It covers the drain past stale replies, the wait that skips them within what is left of the timeout, never
    longer, a cache full of wrong replies, and the plain case. The same test fails on the old function. The module
    builds for 7.2.11 (the release's config, same vermagic) and for 5.4.254. **Not run on a board yet.** Swapping
    `audio_sipc` needs a boot without the audio stack (its modules are permanent once loaded), which was not done
    on F50-B. The first board to boot a release with it should show, after a few plays into FE_ST_VOICE_PCM_P,
    `dropped a stale reply` lines and a FE_ST_DUMP open that works the first time.

