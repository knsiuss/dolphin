#!/usr/bin/env node
"use strict";

const { spawnSync } = require("child_process");
const fs = require("fs");
const path = require("path");

const ROOT = path.join(__dirname, "..");
const SCRIPTS = path.join(ROOT, "skills", "dolphin-protocol", "scripts");
const PKG = require(path.join(ROOT, "package.json"));

const HELP = `dolphin ${PKG.version}

usage: npx dolphin-pod <command> [args]

setup
  install <harness> [dir] [--global]   copy the 12 skills into a harness
                                       (claude | opencode | codex | cursor | agents)
  init                                 create .dolphin/ in the current project
  register <tag> <role> [terminal]     add a session to the roster

run the pod (needs bash + tmux; on Windows use WSL)
  pod <up|status|...> [project]        start / inspect the pod
  say <Author> <@To> <SIGNAL> ...      put a signal on the board
  scan <slop|secrets|pkg> ...          deterministic scanners
  metrics                              outcome metrics from git

  version | help
`;

// Prefer the project's own .dolphin/bin copy (stable path), fall back to the packaged one.
function tool(name) {
  const local = path.join(process.cwd(), ".dolphin", "bin", name);
  return fs.existsSync(local) ? local : path.join(SCRIPTS, name);
}

function run(file, args) {
  const isPy = fs.readFileSync(file, "utf8").startsWith("#!/usr/bin/env python");
  const cmd = isPy ? (process.platform === "win32" ? "python" : "python3") : "bash";
  const r = spawnSync(cmd, [file, ...args], { stdio: "inherit" });
  if (r.error) {
    console.error(`dolphin: cannot run ${cmd} (${r.error.code}). ` +
      (cmd === "bash" ? "Install bash (Git Bash or WSL)." : "Install Python 3."));
    process.exit(1);
  }
  process.exit(r.status === null ? 1 : r.status);
}

const [cmd, ...args] = process.argv.slice(2);

switch (cmd) {
  case "install":  run(path.join(ROOT, "scripts", "dolphin-install.sh"), args); break;
  case "init":     run(path.join(SCRIPTS, "dolphin-init.sh"), args); break;
  case "register": run(path.join(SCRIPTS, "dolphin-init.sh"), ["--register", ...args]); break;
  case "pod":      run(tool("dolphin-pod.sh"), args); break;
  case "say":      run(tool("dolphin-say"), args); break;
  case "scan":     run(tool("dolphin-scan"), args); break;
  case "metrics":  run(tool("dolphin-metrics"), args); break;
  case "version": case "-v": case "--version": console.log(PKG.version); break;
  case undefined: case "help": case "-h": case "--help": console.log(HELP); break;
  default:
    console.error(`dolphin: unknown command "${cmd}"\n`);
    console.error(HELP);
    process.exit(1);
}
