// Help function:
exports.help = (config, command, message) => {
    return "Set certain config variables for this server. You can \`set\` and \`reset\` variables, as well as get \`help\` for each or make me show a \`list\` of the current config state. \nUsage: \`" + config.prefix + command + " [set|reset|help|show] [variable]\` \nExamples: \`" + config.prefix + command + " list\`, \`" + config.prefix + command + " help prefix \`, \`" + config.prefix + command + " set prefix b?\`, \`" + config.prefix + command + "reset prefix\`.";
}
// Command logic:
exports.call = (args, info) => {
    // No response in DMs.
    if (!info.message.guild) {
        return "You can't change settings in DMs! What would that even do!";
    }
    // Only allow staff members to mess with and view settings.
    if (!info.core.isByStaffMember (info.message)) {
        return "You are not authorized to do this.";
    }
    // Help text and function that checks for valid values for each setting.
    var available_settings = {
        "prefix": {
            "help": "The string of letters you need to put in front of each command for me to respond.",
            "legal": value => {
                return value.length >= 1 && value.length <= 20
            },
        },
        "ignore_bots": {
            "help": "Whether I should ignore other bots' messages or not. This might lead to trouble!",
            "legal": value => {
                return value === "true" || value === "false"
            },
        },
        "use_hierarchy": {
            "help": "Whether I should care about whether or not someone is a staff member for critical commands \
							\nI'll use the \`staff_perms\` setting to figure out who meets this.",
            "legal": value => {
                return value === "true" || value === "false"
            },
        },
        "staff_perms": {
            "help": "The permission value that a user needs to fulfill in order to be considered a server staff member. \
							\nCalculate: \`https://finitereality.github.io/permissions-calculator\`",
            "legal": value => {
                return (!isNaN (value)) && parseInt (value, 10) >= 0
            },
        },
        "random_markov": {
            "help": "Whether I should randomly interject with my conversational talents without being asked to sometimes.",
            "legal": value => {
                return value === "true" || value === "false"
            },
        },
        "markov_min_messages": {
            "help": "If `random_markov` is true, how many messages need to pass between each time I talk before I consider joining in.",
            "legal": value => {
                return (!isNaN (value)) && parseFloat (value) >= 0
            },
        },
        "markov_chance": {
            "help": "If `random_markov` is true, how high the chance is for me to respond to someone's message, in percent.",
            "legal": value => {
                return (!isNaN (value)) && parseFloat (value) >= 0.1 && parseFloat (value) <= 128
            },
        },
        "markov_chance_increase": {
            "help": "If `random_markov` is true, each message that does not lure me into talking will lower my patience by this many percent.",
            "legal": value => {
                return (!isNaN (value)) && parseFloat (value) >= 0 && parseFloat (value) <= 128
            },
        },
        "markov_max_length": {
            "help": "The maximum length, in letters, of every markov chain I post. To prevent spam!",
            "legal": value => {
                return (!isNaN (value)) && parseFloat(value) >= 1 && parseFloat(value) <= 2000
            },
        },
        "markov_default_max_words": {
            "help": "The default word limit for every markov response I give. \
			        Since words can be long, this mostly just changes the way I structure my sentences instead of preventing me from rambling on.",
            "legal": value => {
                return (!isNaN (value)) && parseFloat (value) >= 1 && parseFloat (value) <= 512
            },
        },
        "allow_hooks": {
            "help": "Whether I am allowed to listen to message hooks to run commands without a prefix.",
            "legal": value => {
                return value === "true" || value === "false"
            },
        },
    };
    const OVERRIDE = "config_override";
    var flake = info.message.guild.id;
    var guild_mem = info.memory.guilds [flake];
    // Create override object if it doesn't exist yet.
    if (!guild_mem.hasOwnProperty (OVERRIDE)) {
        guild_mem [OVERRIDE] = {};
    }
    var settings = guild_mem [OVERRIDE]
    return info.core.commandSwitch (args, {
        // Set a setting to the given value.
        set: args => {
            // Check if there is enough detail to set a new value.
            if (args.length >= 2) {
                var target_setting = args.shift ();
                var new_value = args.join (" ");
                // If the setting exists and the value is legal, set it.
                if (available_settings.hasOwnProperty (target_setting)) {
                    if (available_settings [target_setting] . legal (new_value)) {
                        if (!isNaN (new_value)) {
                            new_value = parseFloat (new_value);
                        } else if (new_value === "true") {
                            new_value = true;
                        } else if (new_value === "false") {
                            new_value = false;
                        }
                        settings [target_setting] = new_value;
                        return "Set \`" + target_setting + "\` to " + new_value + ".";
                    } else {
                        return "\`" + new_value + " is not an acceptable value for that setting.";
                    }
                } else {
                    return "\`" + target_setting + "\` is not an available setting.";
                }
            } else {
                // If we don't have enough detail to set a new value, report the error.
                return args.length === 0 ?
                    "You need to tell me which setting to change!" :
                    "You need to tell me what to change the setting to!";
            }
        },
        // Reset a setting to the default value.
        reset: args => {
            // Check if we are told which setting to reset.
            if (args.length >= 1) {
                var target_setting = args.shift ();
                if (settings.hasOwnProperty (target_setting)) {
                    delete settings [target_setting];
                }
                return "Reset \`" + target_setting + "\` to default.";
            } else {
                // If we aren't told which setting to reset, we can't.
                return "You need to tell me which setting to reset!";
            }
        },
        // Show the current settings state.
        list: args => {
            var return_string = "";
            Object.keys (available_settings) . forEach (setting => {
                return_string = return_string + "\`" + setting + "\`: **" + info.config [setting] + "**\n";
            });
            return return_string + "\nFor more details about any specific setting, use \`" + info.config.prefix + "config help [setting]\`.";
        },
        help: args => {
            if (args.length >= 1) {
                var target_setting = args.shift ();
                if (available_settings.hasOwnProperty (target_setting)) {
                    var help_string = available_settings [target_setting] . help;
                    return "\`" + target_setting + "\`: **" + info.config [target_setting] + "**\n" + help_string;
                } else {
                    return "\`" + target_setting + "\` is not an available setting.";
                }
            } else {
                return "You need to tell me which setting to get help for!";
            }
        },
        default: function (args) {
            return this.list ();
        },
    });

}
