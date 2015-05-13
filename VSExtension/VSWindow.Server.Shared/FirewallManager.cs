using System;
using System.Collections.ObjectModel;
using System.Linq;

namespace PixelByProxy.VSWindow.Server.Shared
{
    public class FirewallManager
    {
        private const string FirewallRuleName = "VS Window";
        private const string FirewallExeName = "netsh";
        private const string FirewallCheckEnabledVista = "advfirewall show allprofiles";
        private const string FirewallCheckRuleEnabledVista = "advfirewall firewall show rule name=\"VS Window\"";
        private const string FirewallEnablePortInVista = "advfirewall firewall add rule name=\"VS Window\" dir=in action=allow protocol=TCP localport={0}";
        private const string FirewallEnablePortOutVista = "advfirewall firewall add rule name=\"VS Window\" dir=out action=allow protocol=TCP localport={0}";
        private const string FirewallDisableVista = "advfirewall firewall delete rule name=\"VS Window\" protocol=TCP localport={0}";
        private const string FirewallCheckEnabledXp = "firewall show state";
        private const string FirewallCheckRuleEnabledXp = "firewall show portopening";
        private const string FirewallEnableXp = "firewall add portopening TCP {0} \"VS Window\" ENABLE";
        private const string FirewallDisableXp = "firewall delete portopening TCP {0}";
        private const string FirewallCheckVsEnabledVista = "advfirewall firewall show rule name=\"Visual Studio {0} Remote Connection for VS Window\"";
        private const string FirewallEnableVsInVista = "advfirewall firewall add rule name=\"Visual Studio {0} Remote Connection for VS Window\" dir=in action=allow program=\"{1}\" remoteip=localsubnet enable=yes";
        private const string FirewallEnableVsOutVista = "advfirewall firewall add rule name=\"Visual Studio {0} Remote Connection for VS Window\" dir=out action=allow program=\"{1}\" remoteip=localsubnet enable=yes";

        class FirewallRule
        {
            public string Name { get; set; }
            public bool Enabled { get; set; }
            public int Port { get; set; }
            public string Direction { get; set; }
        }

        public bool CheckFirewallEnabled()
        {
            return Environment.OSVersion.Version.Major >= 6 ? CheckFirewallEnabledVista() : CheckFirewallEnabledXp();
        }
        public bool CheckVsWindowPortRuleEnabled(int port)
        {
            return Environment.OSVersion.Version.Major >= 6 ? CheckVsWindowRuleEnabledVista(port) : CheckVsWindowRuleEnabledXp();
        }
        public bool CheckVsWindowProgramRuleEnabled(string exe, int version)
        {
            bool enabled = true;

            if (Environment.OSVersion.Version.Major >= 6)
            {
                enabled = CheckVsWindowProgramEnabledVista(version);
            }

            // FUTURE: Implement for XP
            //enabled = CheckVSWindowRuleEnabledXP();

            return enabled;
        }
        public bool AddProgramFirewallRule(string exe, int version)
        {
            bool added = false;

            if (Environment.OSVersion.Version.Major >= 6)
            {
                added = AddProgramFirewallRuleVista(exe, version);
            }

            // FUTURE: Implement for XP
            //added = AddPortFirewallRuleXP(port);

            return added;
        }
        public bool AddPortFirewallRule(int port)
        {
            return Environment.OSVersion.Version.Major >= 6 ? AddPortFirewallRuleVista(port) : AddPortFirewallRuleXp(port);
        }
        public bool RemovePortFirewallRule(int port)
        {
            return Environment.OSVersion.Version.Major >= 6 ? RemovePortFirewallRuleVista(port) : RemovePortFirewallRuleXp(port);
        }

        private bool CheckFirewallEnabledVista()
        {
            bool enabled = false;
            string output;
            
            if (RunProcess.RunWithOutput(FirewallExeName, null, FirewallCheckEnabledVista, false, out output))
            {
                enabled = output.IndexOf("ON", StringComparison.Ordinal) > -1;
            }

            return enabled;
        }
        private static bool CheckFirewallEnabledXp()
        {
            bool enabled = false;
            string output;

            if (RunProcess.RunWithOutput(FirewallExeName, null, FirewallCheckEnabledXp, false, out output))
            {
                string[] lines = output.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

                foreach (string line in lines)
                {
                    if (line.StartsWith("Operational mode", StringComparison.Ordinal))
                    {
                        enabled = line.IndexOf("Enable", StringComparison.Ordinal) > -1;
                        break;
                    }
                }
            }

            return enabled;
        }
        private static bool CheckVsWindowRuleEnabledVista(int port)
        {
            bool enabled = false;
            string output;

            if (RunProcess.RunWithOutput(FirewallExeName, null, FirewallCheckRuleEnabledVista, false, out output))
            {
                Collection<FirewallRule> rules = new Collection<FirewallRule>();

                string[] lines = output.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

                FirewallRule rule = null;

                foreach (string line in lines)
                {
                    string[] lineParts = line.Split(new[] { "  " }, StringSplitOptions.RemoveEmptyEntries);
                    if (lineParts.Length == 2)
                    {
                        if (line.StartsWith("Rule Name:", StringComparison.Ordinal))
                        {
                            rule = new FirewallRule
                            {
                                Name = lineParts[1]
                            };
                            rules.Add(rule);
                            continue;
                        }

                        if (rule != null && line.StartsWith("Direction:", StringComparison.Ordinal))
                        {
                            rule.Direction = lineParts[1];
                            continue;
                        }

                        if (rule != null && line.StartsWith("Enabled:", StringComparison.Ordinal))
                        {
                            rule.Enabled = line.IndexOf("Yes", StringComparison.Ordinal) > -1;
                            continue;
                        }

                        if (rule != null && line.StartsWith("LocalPort:", StringComparison.Ordinal))
                        {
                            int portNumber;

                            if (int.TryParse(lineParts[1], out portNumber))
                                rule.Port = portNumber;
                        }
                    }
                }

                bool inEnabled = rules.Any(r => r.Enabled && r.Port == port && string.Equals(r.Direction, "In", StringComparison.Ordinal));
                bool outEnabled = rules.Any(r => r.Enabled && r.Port == port && string.Equals(r.Direction, "Out", StringComparison.Ordinal));
                enabled = inEnabled && outEnabled;
            }

            return enabled;
        }
        private static bool CheckVsWindowRuleEnabledXp()
        {
            bool enabled = false;
            string output;

            if (RunProcess.RunWithOutput(FirewallExeName, null, FirewallCheckRuleEnabledXp, false, out output))
            {
                string[] lines = output.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

                foreach (string line in lines)
                {
                    if (line.IndexOf(FirewallRuleName, StringComparison.Ordinal) > -1)
                    {
                        enabled = line.IndexOf("Enable", StringComparison.Ordinal) > -1;
                        break;
                    }
                }
            }

            return enabled;
        }
        private static bool CheckVsWindowProgramEnabledVista(int version)
        {
            bool enabled = false;
            string output;

            if (RunProcess.RunWithOutput(FirewallExeName, null, string.Format(FirewallCheckVsEnabledVista, version), false, out output))
            {
                Collection<FirewallRule> rules = new Collection<FirewallRule>();

                string[] lines = output.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);

                FirewallRule rule = null;

                foreach (string line in lines)
                {
                    string[] lineParts = line.Split(new[] { "  " }, StringSplitOptions.RemoveEmptyEntries);
                    if (lineParts.Length == 2)
                    {
                        if (line.StartsWith("Rule Name:", StringComparison.Ordinal))
                        {
                            rule = new FirewallRule
                            {
                                Name = lineParts[1]
                            };
                            rules.Add(rule);
                            continue;
                        }

                        if (rule != null && line.StartsWith("Direction:", StringComparison.Ordinal))
                        {
                            rule.Direction = lineParts[1];
                            continue;
                        }

                        if (rule != null && line.StartsWith("Enabled:", StringComparison.Ordinal))
                        {
                            rule.Enabled = line.IndexOf("Yes", StringComparison.Ordinal) > -1;
                        }
                    }
                }

                bool inEnabled = rules.Any(r => r.Enabled && string.Equals(r.Direction, "In", StringComparison.Ordinal));
                bool outEnabled = rules.Any(r => r.Enabled && string.Equals(r.Direction, "Out", StringComparison.Ordinal));
                enabled = inEnabled && outEnabled;
            }

            return enabled;
        }
        private bool AddPortFirewallRuleVista(int port)
        {
            bool inAdded = RunProcess.Run(FirewallExeName, null, string.Format(FirewallEnablePortInVista, port), false, true);
            bool outAdded = RunProcess.Run(FirewallExeName, null, string.Format(FirewallEnablePortOutVista, port), false, true);

            return (inAdded && outAdded);
        }
        private static bool AddPortFirewallRuleXp(int port)
        {
            return RunProcess.Run(FirewallExeName, null, string.Format(FirewallEnableXp, port), false, true);
        }
        private bool RemovePortFirewallRuleVista(int port)
        {
            return RunProcess.Run(FirewallExeName, null, string.Format(FirewallDisableVista, port), false, true);
        }
        private static bool RemovePortFirewallRuleXp(int port)
        {
            return RunProcess.Run(FirewallExeName, null, string.Format(FirewallDisableXp, port), false, true);
        }
        private bool AddProgramFirewallRuleVista(string exe, int version)
        {
            bool inAdded = RunProcess.Run(FirewallExeName, null, string.Format(FirewallEnableVsInVista, version, exe), false, true);
            bool outAdded = RunProcess.Run(FirewallExeName, null, string.Format(FirewallEnableVsOutVista, version, exe), false, true);

            return (inAdded && outAdded);
        }
    }
}