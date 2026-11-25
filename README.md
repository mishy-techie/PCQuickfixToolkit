# PC Quick Fix Toolkit

A simple, menu-driven Windows script that fixes common PC problems and explains the results in plain English. No installation needed.

**One click:** choose option 1 and the toolkit checks your PC, fixes the safe stuff, and tells you what it did.

## What it does

| Option | What happens |
|---|---|
| 1. Fix my PC automatically | Checks internet, clears temp files, checks the print service, and gives a plain-English summary |
| 2. Fix internet problems | Tests your connection, refreshes DNS, and offers a deeper network reset |
| 3. Free up space | Clears temporary files and shows free space before and after |
| 4. PC health report | Shows an "at a glance" summary and saves a full report to your Desktop |
| 5. Check and repair Windows files | Runs Windows System File Checker (`sfc /scannow`) and explains the result |
| 6. Fix printer problems | Clears stuck print jobs and restarts the print service |
| 7. Reset Windows Update | Resets update components when Windows Update is stuck or failing |

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

Run from Command Prompt or deploy via your management tool:

```
PC-Quick-Fix-Toolkit.cmd /auto         Check and fix common problems, print summary
PC-Quick-Fix-Toolkit.cmd /report       Save health report to Desktop
PC-Quick-Fix-Toolkit.cmd /flushdns     Flush DNS cache
PC-Quick-Fix-Toolkit.cmd /cleantemp    Clear temp files
PC-Quick-Fix-Toolkit.cmd /fixprinter   Clear print queue, restart spooler (admin)
PC-Quick-Fix-Toolkit.cmd /resetupdate  Reset Windows Update components (admin)
PC-Quick-Fix-Toolkit.cmd /help         Show help
```

## Requirements

Windows 10 or 11. Uses only built-in tools (PowerShell, ipconfig, netsh, sfc).

## License

MIT. Free to use, share and modify.
