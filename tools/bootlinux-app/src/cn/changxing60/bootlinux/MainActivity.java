package cn.changxing60.bootlinux;

import android.app.Activity;
import android.app.AlertDialog;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.Locale;
import java.util.zip.CRC32;

/**
 * 一键从 Android 重启到 Linux/OpenWrt。
 *
 * 原理和 work/arm-linux.sh 完全一样：往 misc 分区偏移 2048 处写 32 字节的 bootloader_control，
 * 把 slot b 标成待启动，然后重启。boot_b 上的 Linux 镜像不动，只改这一个标志位；Linux 起不来时
 * LK 会自己落回 Android。
 *
 * 没有后台服务、没有定时任务，只在按钮被按下时才动 misc。
 *
 * 启动记录不写死：每次动作都从设备当前 misc 读取 bootloader_control，校验 CRC，
 * 再按 7552N 的规则派生 slot-b 试启动记录。这样不会把另一台设备或旧备份的 32 字节
 * 记录误写进本机 misc。
 */
public class MainActivity extends Activity {

    private static final String MISC = "/dev/block/by-name/misc";
    private static final int MISC_OFFSET = 2048;

    private final Handler ui = new Handler(Looper.getMainLooper());

    private TextView status;
    private Button go;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(buildUi());
        refreshStatus();
    }

    // ---------------------------------------------------------------- UI

    private View buildUi() {
        int pad = dp(24);

        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(0xFF101418);
        root.setPadding(pad, dp(56), pad, pad);

        TextView title = new TextView(this);
        title.setText("重启到 Linux");
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 26);
        title.setTextColor(0xFFF2F5F7);
        title.setTypeface(Typeface.DEFAULT_BOLD);
        root.addView(title);

        TextView desc = new TextView(this);
        desc.setText("写入引导标志后重启。boot_b 上的 Linux 不动，只改 misc 里 32 字节的启动标志；"
                + "Linux 起不来时引导器会自己落回 Android。");
        desc.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        desc.setTextColor(0xFF9AA6B2);
        desc.setLineSpacing(dp(6), 1f);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.topMargin = dp(14);
        root.addView(desc, lp);

        status = new TextView(this);
        status.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);
        status.setTextColor(0xFF7FD1AE);
        status.setLineSpacing(dp(4), 1f);
        LinearLayout.LayoutParams slp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        slp.topMargin = dp(28);
        root.addView(status, slp);

        View spacer = new View(this);
        root.addView(spacer, new LinearLayout.LayoutParams(0, 0, 1f));

        go = new Button(this);
        go.setText("重启到 Linux");
        go.setAllCaps(false);
        go.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
        go.setTextColor(0xFF07120C);
        go.setBackgroundColor(0xFF4ADE80);
        go.setOnClickListener(v -> confirm());
        root.addView(go, new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, dp(56)));

        TextView foot = new TextView(this);
        foot.setText("需要 root（Magisk 的 su）。");
        foot.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        foot.setTextColor(0xFF5C6773);
        foot.setGravity(Gravity.CENTER);
        LinearLayout.LayoutParams flp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        flp.topMargin = dp(14);
        root.addView(foot, flp);

        return root;
    }

    private int dp(int v) {
        return Math.round(getResources().getDisplayMetrics().density * v);
    }

    // ------------------------------------------------------------ 状态检查

    private void refreshStatus() {
        new Thread(() -> {
            String root = run("id -u").trim();
            String slot = run("getprop ro.boot.slot_suffix").trim();
            boolean haveRoot = "0".equals(root);

            String bcb = haveRoot ? readBcb() : "";
            boolean bcbOk = validateBcbHex(bcb, true) == null;
            String text = "root：" + (haveRoot ? "已授权" : "没有（su 不可用）")
                    + "\n当前系统槽位：" + (TextUtils.isEmpty(slot) ? "未知" : slot);

            if (haveRoot) {
                text += "\n启动记录：" + (bcbOk ? "已校验" : "不可用");
            }

            if (haveRoot && !"_a".equals(slot)) {
                text += "\n\n注意：Android 应该跑在 slot a 上。现在不是，引导标志可能对不上。";
            }

            final String t = text;
            final boolean enabled = haveRoot && "_a".equals(slot) && bcbOk;
            ui.post(() -> {
                status.setText(t);
                go.setEnabled(enabled);
                go.setAlpha(enabled ? 1f : 0.4f);
            });
        }).start();
    }

    // -------------------------------------------------------------- 动作

    private void confirm() {
        new AlertDialog.Builder(this)
                .setTitle("重启到 Linux？")
                .setMessage("会读取并校验当前 misc，然后只改写其中 32 字节的启动标志到 slot b，最后立即重启。\n\n"
                        + "想回 Android，在 Linux 里 poweroff -f 或正常重启即可。")
                .setNegativeButton("取消", null)
                .setPositiveButton("重启", (d, w) -> doIt())
                .show();
    }

    private void doIt() {
        go.setEnabled(false);
        status.setTextColor(0xFF9AA6B2);
        status.setText("正在写入引导标志…");

        new Thread(() -> {
            String slot = run("getprop ro.boot.slot_suffix").trim();
            if (!"_a".equals(slot)) {
                fail("当前不是 Android slot _a，已停止，没有写入 misc。\n当前：" + slot);
                return;
            }

            String live = readBcb();
            String problem = validateBcbHex(live, true);
            if (problem != null) {
                fail("当前 misc 启动记录校验失败，没有写入：\n" + problem);
                return;
            }
            String trial = deriveSlotB(live);

            // 把两个精确的 32 字节记录落到应用缓存，让 root 去 dd；不在 shell 里拼二进制。
            File before = new File(getCacheDir(), "bc-before.bin");
            File blob = new File(getCacheDir(), "bc-slot-b.bin");
            try (OutputStream out = new FileOutputStream(blob)) {
                out.write(hex(trial));
            } catch (Exception e) {
                fail("写临时文件失败：" + e.getMessage());
                return;
            }
            try (OutputStream out = new FileOutputStream(before)) {
                out.write(hex(live));
            } catch (Exception e) {
                fail("写临时文件失败：" + e.getMessage());
                return;
            }

            String qBefore = shellQuote(before.getAbsolutePath());
            String qBlob = shellQuote(blob.getAbsolutePath());
            String write = "set -e; live=$(dd if=" + MISC + " bs=1 skip=" + MISC_OFFSET
                    + " count=32 2>/dev/null | od -An -tx1 -v | tr -d ' \\n'); "
                    + "[ \"$live\" = \"" + live + "\" ]; "
                    + "dd if=" + qBlob + " of=" + MISC
                    + " bs=1 seek=" + MISC_OFFSET + " count=32 conv=notrunc 2>&1; sync; echo DD_OK";
            String r1 = run(write);
            if (!r1.contains("DD_OK")) {
                fail("写入 misc 失败或启动记录已变化，没有重启：\n" + r1.trim());
                return;
            }

            // 读回来核对，和 arm-linux.sh 一样，不盲信 dd 的返回值。
            String read = "dd if=" + MISC + " bs=1 skip=" + MISC_OFFSET
                    + " count=32 2>/dev/null | od -An -tx1 -v | tr -d ' \\n'";
            String got = run(read).trim().toLowerCase();
            if (!trial.equals(got)) {
                // 读回不一致时，用本次动作前保存的精确记录恢复；恢复失败也不重启。
                String restore = "dd if=" + qBefore + " of=" + MISC
                        + " bs=1 seek=" + MISC_OFFSET + " count=32 conv=notrunc 2>&1; sync; echo RESTORED";
                String rr = run(restore);
                String back = run(read).trim().toLowerCase();
                if (!rr.contains("RESTORED") || !live.equals(back)) {
                    fail("校验不一致，且恢复失败；没有重启。\n读到：" + got);
                } else {
                    fail("校验不一致，已恢复原启动记录，没有重启。\n读到：" + got);
                }
                return;
            }

            ui.post(() -> status.setText("引导标志已写入并校验通过，正在重启…"));
            run("reboot");
        }).start();
    }

    private void fail(String msg) {
        ui.post(() -> {
            status.setTextColor(0xFFFF7B72);
            status.setText(msg);
            go.setEnabled(true);
        });
    }

    // -------------------------------------------------------------- 工具

    /** 用 su 跑一段 shell，返回合并后的 stdout+stderr。 */
    private String run(String cmd) {
        Process p = null;
        try {
            p = new ProcessBuilder("su", "-c", cmd).redirectErrorStream(true).start();
            StringBuilder sb = new StringBuilder();
            try (BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream()))) {
                String line;
                while ((line = r.readLine()) != null) sb.append(line).append('\n');
            }
            p.waitFor();
            return sb.toString();
        } catch (Exception e) {
            return e.getClass().getSimpleName() + ": " + e.getMessage();
        } finally {
            if (p != null) p.destroy();
        }
    }

    private String readBcb() {
        return run("dd if=" + MISC + " bs=1 skip=" + MISC_OFFSET
                + " count=32 2>/dev/null | od -An -tx1 -v | tr -d ' \\n'")
                .trim().toLowerCase(Locale.US);
    }

    /** Return null when valid, otherwise a short human-readable reason. */
    private static String validateBcbHex(String hex, boolean requireAndroid) {
        if (hex == null || hex.length() != 64) return "长度不是 32 字节";
        byte[] b;
        try {
            b = hex(hex);
        } catch (RuntimeException e) {
            return "不是十六进制记录";
        }
        if ((b[0] != '_' || (b[1] != 'a' && b[1] != 'b')) || b[2] != 0 || b[3] != 0)
            return "slot 后缀不是 _a/_b";
        if (b[4] != 'B' || b[5] != 'C' || b[6] != 'A' || b[7] != 'B')
            return "没有 BCAB magic";
        if (requireAndroid && b[1] != 'a') return "当前 misc 不是 slot-a 记录";
        if (b[9] < 2 || b[9] > 4) return "slot 数量异常";
        for (int i = 20; i < 28; i++) if (b[i] != 0) return "reserved 字节非零";
        for (int off = 12; off < 12 + 2 * b[9]; off += 2) {
            int info = b[off] & 0xff;
            if (b[off + 1] != 0) return "slot metadata 保留字节非零";
            if ((info & 0x0f) > 15 || ((info >>> 4) & 0x07) > 7)
                return "slot metadata 越界";
        }
        CRC32 crc = new CRC32();
        crc.update(b, 0, 28);
        long want = ((long) b[28] & 0xff) | (((long) b[29] & 0xff) << 8)
                | (((long) b[30] & 0xff) << 16) | (((long) b[31] & 0xff) << 24);
        if (crc.getValue() != want) return "CRC 不匹配";
        return null;
    }

    /** Derive the slot-b trial record from the exact live record, matching build-boot-image.py. */
    private static String deriveSlotB(String liveHex) {
        byte[] b = hex(liveHex);
        b[0] = '_'; b[1] = 'b'; b[2] = 0; b[3] = 0;
        b[14] = 0x2f; // slot b: priority 15, tries 2, successful 0
        b[12] = (byte) ((b[12] & 0xf0) | Math.min(b[12] & 0x0f, 14));
        CRC32 crc = new CRC32();
        crc.update(b, 0, 28);
        long v = crc.getValue();
        b[28] = (byte) v; b[29] = (byte) (v >>> 8);
        b[30] = (byte) (v >>> 16); b[31] = (byte) (v >>> 24);
        return hex(b);
    }

    private static String shellQuote(String path) {
        return "'" + path.replace("'", "'\\''") + "'";
    }

    private static byte[] hex(String s) {
        int n = s.length() / 2;
        byte[] out = new byte[n];
        for (int i = 0; i < n; i++) {
            out[i] = (byte) Integer.parseInt(s.substring(i * 2, i * 2 + 2), 16);
        }
        return out;
    }

    private static String hex(byte[] b) {
        StringBuilder s = new StringBuilder(b.length * 2);
        for (byte x : b) s.append(String.format(Locale.US, "%02x", x & 0xff));
        return s.toString();
    }
}
