// Minimal ALSA PCM player for bring-up. No alsa-lib: talks to /dev/snd/pcmC*D* with the
// raw ioctl ABI from <sound/asound.h>. Enough to prove the card moves samples.
//
//   pcmplay <device> <seconds> [freq_hz]
//
// device is like /dev/snd/pcmC0D0p.
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include <sound/asound.h>

#define RATE     48000
#define CHANNELS 2
#define PERIOD   1024

static void set_mask(struct snd_pcm_hw_params *p, int var, unsigned int val)
{
	struct snd_mask *m = &p->masks[var - SNDRV_PCM_HW_PARAM_FIRST_MASK];
	m->bits[val / 32] |= 1u << (val % 32);
}

static void set_fixed(struct snd_pcm_hw_params *p, int var, unsigned int v)
{
	struct snd_interval *i = &p->intervals[var - SNDRV_PCM_HW_PARAM_FIRST_INTERVAL];
	i->min = i->max = v;
	i->integer = 1;
}

static void set_range(struct snd_pcm_hw_params *p, int var, unsigned int lo,
		      unsigned int hi)
{
	struct snd_interval *i = &p->intervals[var - SNDRV_PCM_HW_PARAM_FIRST_INTERVAL];
	i->min = lo;
	i->max = hi;
	i->integer = 1;
}

int main(int argc, char **argv)
{
	const char *dev = argc > 1 ? argv[1] : "/dev/snd/pcmC0D0p";
	double secs = argc > 2 ? atof(argv[2]) : 5.0;
	double freq = argc > 3 ? atof(argv[3]) : 600.0;
	struct snd_pcm_hw_params p;
	struct snd_xferi xfer;
	int16_t buf[PERIOD * CHANNELS];
	unsigned int rate = RATE;
	long total, written = 0;
	int fd, rc;
	unsigned int i;

	fd = open(dev, O_WRONLY);
	if (fd < 0)
		fd = open(dev, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "open %s: %s\n", dev, strerror(errno));
		return 1;
	}

	memset(&p, 0, sizeof(p));
	set_mask(&p, SNDRV_PCM_HW_PARAM_ACCESS, SNDRV_PCM_ACCESS_RW_INTERLEAVED);
	set_mask(&p, SNDRV_PCM_HW_PARAM_FORMAT, SNDRV_PCM_FORMAT_S16_LE);
	set_mask(&p, SNDRV_PCM_HW_PARAM_SUBFORMAT, SNDRV_PCM_SUBFORMAT_STD);
	set_fixed(&p, SNDRV_PCM_HW_PARAM_CHANNELS, CHANNELS);
	set_fixed(&p, SNDRV_PCM_HW_PARAM_RATE, rate);
	set_range(&p, SNDRV_PCM_HW_PARAM_PERIOD_SIZE, PERIOD, PERIOD);
	set_range(&p, SNDRV_PCM_HW_PARAM_BUFFER_SIZE, PERIOD * 4, PERIOD * 4);
	set_range(&p, SNDRV_PCM_HW_PARAM_PERIODS, 4, 4);

	rc = ioctl(fd, SNDRV_PCM_IOCTL_HW_PARAMS, &p);
	if (rc < 0) {
		fprintf(stderr, "HW_PARAMS: %s\n", strerror(errno));
		return 1;
	}
	fprintf(stderr, "hw params ok: rate=%u ch=%u period=%u buffer=%u\n",
		RATE, CHANNELS, PERIOD, PERIOD * 4);

	rc = ioctl(fd, SNDRV_PCM_IOCTL_PREPARE, 0);
	if (rc < 0) {
		fprintf(stderr, "PREPARE: %s\n", strerror(errno));
		return 1;
	}

	total = (long)(secs * RATE);
	while (written < total) {
		unsigned int n = PERIOD;
		if (total - written < (long)n)
			n = (unsigned int)(total - written);
		for (i = 0; i < n; i++) {
			double t = (double)(written + i) / RATE;
			int16_t s = (int16_t)(12000.0 * sin(2.0 * M_PI * freq * t));
			buf[i * CHANNELS + 0] = s;
			buf[i * CHANNELS + 1] = s;
		}
		xfer.buf = buf;
		xfer.frames = n;
		rc = ioctl(fd, SNDRV_PCM_IOCTL_WRITEI_FRAMES, &xfer);
		if (rc < 0) {
			fprintf(stderr, "write @%ld: %s\n", written, strerror(errno));
			break;
		}
		written += n;
	}

	ioctl(fd, SNDRV_PCM_IOCTL_DRAIN, 0);
	ioctl(fd, SNDRV_PCM_IOCTL_HW_FREE, 0);
	close(fd);
	fprintf(stderr, "played %ld frames (%.1f s)\n", written, secs);
	return 0;
}
