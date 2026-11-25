# PC Quick Fix Toolkit

A simple, menu-driven Windows script that fixes common PC problems and explains the results in plain English. One file, nothing to install.

**Version 1.1** | Windows 10 and 11 | Free and open source

> **Quick start:** download `PC-Quick-Fix-Toolkit.cmd`, double-click it, press **1**, and read the summary.

## What it does

| Option | What happens |
|---|---|
| 1. Fix my PC automatically | Checks internet, clears temp files, checks the print service, and gives a plain-English summary |
| 2. Fix internet problems | Tests your connection, refreshes DNS, and offers a deeper network reset |
| 3. Free up space | Clears temporary files and shows free space before and after |
| 4. PC health report | Shows an "at a glance" summary and saves a full report to your Desktop |
| 5. Check and repair Windows files | Runs System File Checker (`sfc /scannow`) and explains the result |
| 6. Fix printer problems | Clears stuck print jobs and restarts the print service |
| 7. Reset Windows Update | Resets update components when Windows Update is stuck or failing |
| 8. Check hardware and Windows health | Read-only checkup: drive health, processor, memory, battery wear, device errors, system components, pending restart, antivirus, firewall and update age |

## Is it safe?

- Never deletes personal files (documents, photos, downloads).
- Asks before any bigger action and explains what it will do.
- Creates a **System Restore point** before bigger repairs (network reset, file repair, Windows Update reset). Windows allows one per day by default, and System Protection must be on.
- Plain text script: right-click, choose **Edit**, and read every line before running it.
- Every action is logged to `PC-Toolkit-Log.txt` on your Desktop.

To undo a repair: open the Start menu, type **Create a restore point**, and choose **System Restore**.

## How to use (everyone)

1. Download `PC-Quick-Fix-Toolkit.cmd`.
2. Double-click it.
3. Press **1** and read the summary.

If Windows shows a "protected your PC" message, click **More info**, then **Run anyway** (only if you trust the source and have read the script).

Some fixes need administrator permission. The toolkit offers to restart itself as administrator when needed.

## For IT professionals

Run from Command Prompt or deploy through your management tool:

```
PC-Quick-Fix-Toolkit.cmd /auto         Check and fix common problems, print summary
PC-Quick-Fix-Toolkit.cmd /check        Hardware and Windows health check (no changes)
PC-Quick-Fix-Toolkit.cmd /report       Save health report to Desktop
PC-Quick-Fix-Toolkit.cmd /flushdns     Flush DNS cache
PC-Quick-Fix-Toolkit.cmd /cleantemp    Clear temp files
PC-Quick-Fix-Toolkit.cmd /fixprinter   Clear print queue, restart spooler (admin)
PC-Quick-Fix-Toolkit.cmd /resetupdate  Reset Windows Update components (admin)
PC-Quick-Fix-Toolkit.cmd /help         Show help
```

## What the health check does not cover

Temperatures, fan speeds and a deep memory test. For memory, search the Start menu for **Windows Memory Diagnostic**. Some checks (Windows component health, battery wear) need administrator permission; the toolkit marks anything it could not check.

## Using a phone?

A .cmd file only runs on Windows, so it will not run on Android or iPhone. You can still:

- Download or share the script from your phone, then open it on a Windows PC.
- Control a Windows PC from your phone with Microsoft Remote Desktop or Chrome Remote Desktop.
- Read the **[Phone Troubleshooting Guide](PHONE-TROUBLESHOOTING.md)** for fixing common Android and iPhone problems.

## Requirements

Windows 10 or 11. Uses only built-in tools (PowerShell, ipconfig, netsh, sfc, DISM).

## License

MIT. Free to use, share and modify.

---

&copy; 2026 Mishy Techie
