bzr_revno = `bzr revno .`.to_i + 1

rbloomberg_description = File.read("rbloomberg/DESCRIPTION") rescue nil
rbloomberg_description ||= File.read("../rbloomberg/DESCRIPTION")

raise "rbloomberg version not found" unless rbloomberg_description =~ /^Version:\s[0-9]+\.[0-9]+-([0-9]+)\s*$/
rbloomberg_version = $1.to_i

raise "rbloomberg version should be #{bzr_revno} but is #{rbloomberg_version}" unless rbloomberg_version == bzr_revno
rbloomberg_version
