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

/**
 * 一键从 Android 重启到 OpenWrt。
 *
 * 原理和 work/arm-linux.sh 完全一样：往 misc 分区偏移 2048 处写 32 字节的 bootloader_control，
 * 把 slot b 标成待启动，然后重启。boot_b 上的 Linux 镜像不动，只改这一个标志位；Linux 起不来时
 * LK 会自己落回 Android。
 *
 * 没有后台服务、没有定时任务，只在按钮被按下时才动 misc。
 */
public class MainActivity extends Activity {

    /** slot b 的 bootloader_control，取自 work/boot-linux-slotb.misc-slot-b-trial.bin。 */
    private static final String BLOB_HEX =
            "5f6200004243414201020000fe002f000000000000000000000000001c751554";

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
        title.setText("重启到 OpenWrt");
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 26);
        title.setTextColor(0xFFF2F5F7);
        title.setTypeface(Typeface.DEFAULT_BOLD);
        root.addView(title);

        TextView desc = new TextView(this);
        desc.setText("写入引导标志后重启。boot_b 上的系统不动，只改 misc 里 32 字节的启动标志；"
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
        go.setText("重启到 OpenWrt");
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

            String text = "root：" + (haveRoot ? "已授权" : "没有（su 不可用）")
                    + "\n当前系统槽位：" + (TextUtils.isEmpty(slot) ? "未知" : slot);

            if (haveRoot && !"_a".equals(slot)) {
                text += "\n\n注意：Android 应该跑在 slot a 上。现在不是，引导标志可能对不上。";
            }

            final String t = text;
            final boolean enabled = haveRoot;
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
                .setTitle("重启到 OpenWrt？")
                .setMessage("会把 misc 里的启动标志改成 slot b，然后立即重启。\n\n"
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
            // 先把 32 字节落到应用自己的缓存目录，让 root 去 dd 它 —— 比在 shell 里拼转义字符串稳。
            File blob = new File(getCacheDir(), "bc.bin");
            try (OutputStream out = new FileOutputStream(blob)) {
                out.write(hex(BLOB_HEX));
            } catch (Exception e) {
                fail("写临时文件失败：" + e.getMessage());
                return;
            }

            String write = "dd if=" + blob.getAbsolutePath() + " of=" + MISC
                    + " bs=1 seek=" + MISC_OFFSET + " conv=notrunc 2>&1 && sync && echo DD_OK";
            String r1 = run(write);
            if (!r1.contains("DD_OK")) {
                fail("写入 misc 失败：\n" + r1.trim());
                return;
            }

            // 读回来核对，和 arm-linux.sh 一样，不盲信 dd 的返回值。
            String read = "dd if=" + MISC + " bs=1 skip=" + MISC_OFFSET
                    + " count=32 2>/dev/null | od -An -tx1 -v | tr -d ' \\n'";
            String got = run(read).trim().toLowerCase();
            String want = BLOB_HEX.toLowerCase();
            if (!want.equals(got)) {
                fail("校验不一致，没有重启。\n读到：" + got + "\n应为：" + want);
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

    private static byte[] hex(String s) {
        int n = s.length() / 2;
        byte[] out = new byte[n];
        for (int i = 0; i < n; i++) {
            out[i] = (byte) Integer.parseInt(s.substring(i * 2, i * 2 + 2), 16);
        }
        return out;
    }
}
