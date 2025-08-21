Tacky = SMODS.current_mod

Tacky.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = { align = "m", r = 0.1, padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6 },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = "cm", padding = 0.05 },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "tm", padding = 0.2 },
                        nodes = { { n = G.UIT.T, config = { text = "Gameplay Settings", colour = G.C.UI.TEXT_LIGHT, scale = 0.5 } } }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "tm" },
                        nodes = {
                            create_toggle { col = true, label = 'Crook Use Button', scale = 1, w = 0, shadow = true, ref_table = Tacky.config, ref_value = "crook_button",
                                tooltip = {} },
                            create_toggle { col = true, label = 'Only Tacky Jokers', scale = 1, w = 0, shadow = true, ref_table = Tacky.config, ref_value = "tacky_only" },
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.2 },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {{ n = G.UIT.T, config = { text = 'Art, ideas and concepts by @Tacashumi', colour = G.C.UI.TEXT_INACTIVE, scale = 0.4 } }}
                            },
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {{ n = G.UIT.T, config = { text = 'Coding by me, Fey :p', colour = G.C.UI.TEXT_INACTIVE, scale = 0.4 } }}
                            }
                        }
                    }
                }
            }
        }
    }
end
