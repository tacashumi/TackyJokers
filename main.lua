assert(SMODS.load_file('src/hooks.lua'))()
assert(SMODS.load_file('src/challenges.lua'))()
assert(SMODS.load_file('src/config_tab.lua'))()

--Wasteful Joker
SMODS.Joker {
    key = 'wasteful',
    loc_txt = { name = 'Wasteful Joker',
        text = { 'Gain {C:mult}+#2#{} Mult Per {C:discard}Discard{} Used',
            '{C:mult}-#2#{} Mult Per Played {C:hand}Hand{}',
            '{s:0.8,C:inactive}(Currently {C:mult,s:0.8}+#3#{C:inactive,s:0.8} Mult)' } },
    cost = 5,
    order = 1,
    atlas = 'wasteful',
    rarity = 1,
    discovered = true,
    blueprint_compat = true,
    config = { extra = { mult = 0, mult_gain = 2, mult_loss = 2 } },
    loc_vars = function(self, info_queue, center)
        if center.ability.extra.mult < 0 then center.ability.extra.mult = 0 end
        return {
            vars = {
                center.ability.extra.mult_gain,
                center.ability.extra.mult_loss,
                center.ability.extra.mult
            }
        }
    end,
    calculate = function(card, card, context)
        if context.before and context.cardarea == G.jokers and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult - card.ability.extra.mult_loss
            return {
                message = localize { type = 'variable', key = 'a_mult_minus', vars = { card.ability.extra.mult_loss } },
                colour = G.C.RED,
            }
        end
        if context.pre_discard and context.cardarea == G.jokers and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult_gain } },
                colour = G.C.RED,
            }
        end
        if context.joker_main then
            if card.ability.extra.mult < 0 then card.ability.extra.mult = 0 end
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Atlas {
    key = 'wasteful',
    path = 'Wasteful_Joker.png',
    px = 71,
    py = 95
}

--Crumbly Joker
SMODS.Joker {
    key = 'crumbly',
    loc_txt = { name = 'Crumbly Joker',
        text = { '{C:chips}+#2#{} Chips when any Card is {C:attention}Scored',
            '{s:0.8,C:inactive}(Currently {s:0.8,C:chips}+#2#{s:0.8,C:inactive} Chips)' } },
    cost = 7,
    atlas = 'crumbly',
    rarity = 1,
    order = 2,
    blueprint_compat = true,
    perishable_compat = false,
    config = { extra = { chips = 0, chip_mod = 2 } },
    discovered = true,
    loc_vars = function(card, info_queue, center)
        return {
            vars = {
                center.ability.extra.chip_mod,
                center.ability.extra.chips
            }
        }
    end,
    calculate = function(card, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            return {
                message = '+' .. card.ability.extra.chip_mod .. ' Chips',
                message_card = card,
                colour = G.C.CHIPS
            }
        end
        if context.joker_main and card.ability.extra.chips > 0 then
            return {
                chip_mod = card.ability.extra.chips,
                message = '+' .. card.ability.extra.chips .. ' Chips',
                colour = G.C.CHIPS
            }
        end
    end
}

SMODS.Atlas {
    key = 'crumbly',
    path = 'Crumbly_Joker.png',
    px = 71,
    py = 95
}

--Tacky Joker
SMODS.Joker {
    key = 'tacky',
    atlas = 'tacky',
    order = 3,
    loc_txt = { name = 'Tacky Joker',
        text = {
            'Gain {C:money}$#1#{} on Scoring any {C:attention}Odd',
            'Numbered Cards {C:inactive}(A, 3, 5, 7, 9)'
        } },
    discovered = true,
    cost = 6,
    rarity = 2,
    blueprint_compat = true,
    config = { extra = { dollars = 1 } },
    loc_vars = function(card, info_queue, center)
        return {
            vars = {
                center.ability.extra.dollars
            }
        }
    end,
    calculate = function(card, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card.base.id
            if id == 14 or id == 3 or id == 5 or id == 7 or id == 9 then
                return {
                    dollars = card.ability.extra.dollars
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'tacky',
    path = 'Tacky_Joker.png',
    px = 71,
    py = 95
}

--The Closet
SMODS.Joker {
    key = 'closet',
    atlas = 'closet',
    rarity = 1,
    cost = 3,
    blueprint_compat = false,
    eternal_compat = false,
    loc_txt = { name = 'The Closet',
        text = {
            'After Playing #1# {C:inactive}(#2#){} {C:attention}Straights,',
            'sell this card to add {C:dark_edition}Polychrome',
            'to a random {C:attention}Joker'
        } },
    config = { extra = { req = 3, cur = 0 } },
    discovered = true,
    loc_vars = function(card, info_queue, center)
        return {
            vars = {
                center.ability.extra.req,
                center.ability.extra.cur
            }
        }
    end,
    calculate = function(card, card, context)
        if context.before and context.scoring_name == 'Straight' then
            local eval = function(card)
                return (card.ability.extra.cur >= card.ability.extra.req)
            end
            juice_card_until(card, eval, true)
            card.ability.extra.cur = card.ability.extra.cur + 1
            return {
                message = card.ability.extra.cur .. '...',
                colour = G.C.DARK_EDITION
            }
        end
        if context.selling_card then
            if card.ability.extra.cur >= card.ability.extra.req then
                local editionless = {}
                for i, v in ipairs(G.jokers.cards) do
                    if v.edition == nil then
                        table.insert(editionless, v)
                    end
                end
                if #editionless > 0 then
                    local _card = pseudorandom_element(editionless, pseudoseed('closet'))
                    _card:set_edition('e_polychrome')
                end
            end
        end
    end
}

SMODS.Atlas {
    key = 'closet',
    path = 'The_Closet.png',
    px = 71,
    py = 95
}

--Hack-er

SMODS.Joker {
    key = 'hacker',
    atlas = 'hack-er',
    loc_txt = { name = 'Hack-er',
        text = {
            'Every played {C:attention}2, 3, 4 and 5{} permanently',
            'gains {C:mult}+#2#{} Mult when scored' } },
    cost = 5,
    loc_vars = function(card, info_queue, center)
        return {
            vars = {
                center.ability.extra.bonus
            }
        }
    end,
    rarity = 2,
    discovered = true,
    config = { extra = { bonus = 2 } },
    calculate = function(card, card, context)
        if context.individual and context.cardarea == G.play then
            local _card = context.other_card
            if _card.base.id == 2 or _card.base.id == 3 or _card.base.id == 4 or _card.base.id == 5 then
                _card.ability.perma_mult = _card.ability.perma_mult + card.ability.extra.bonus
                return {
                    message = localize('k_upgrade_ex'), colour = G.C.MULT
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'hack-er',
    path = 'j_hack_er.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'mirror',
    atlas = 'mirror',
    blueprint_compat = true,
    discovered = true,
    loc_txt = { name = 'The Mirror',
        text = {
            'If hand contains {C:attention}5{} scoring',
            'cards, retrigger each card',
            '{C:attention}#1#{} time' } },
    loc_vars = function(card, info_queue, center)
        return {
            vars = {
                center.ability.extra.ret
            }
        }
    end,
    config = { extra = { ret = 1 } },
    cost = 11,
    rarity = 3,
    calculate = function(card, card, context)
        if context.repetition and context.cardarea == G.play then
            local scored = true
            for i, v in ipairs(G.play.cards) do
                if v.debuff then
                    scored = false
                end
            end
            if #context.scoring_hand == 5 and scored == true then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.ret,
                    card = card
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'mirror',
    path = 'The_Mirror.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'conquest',
    cost = 9,
    rarity = 3,
    atlas = 'conquest',
    loc_txt = { name = 'Conquest',
        text = {
            'The {C:attention}lowest{} ranked played card',
            'has its rank upgraded by {C:attention}1{},',
            'unless its an {C:attention}Ace' } },
    blueprint_compat = false,
    calculate = function(card, card, context)
        if context.before then
            local min = 14
            local minsuit = nil
            local mincard = nil
            for i, v in ipairs(G.play.cards) do
                if v.base.id < min then
                    min = v.base.id
                    mincard = v
                    minsuit = string.sub(v.base.suit, 1, 1)
                end
            end
            if min < 14 then
                min = min + 1
                if min == 10 then
                    min = 'T'
                elseif min == 11 then
                    min = 'J'
                elseif min == 12 then
                    min = 'Q'
                elseif min == 13 then
                    min = 'K'
                elseif min == 14 then
                    min = 'A'
                end
                mincard:set_base(G.P_CARDS[minsuit .. '_' .. (min)])
            end
        end
    end
}

SMODS.Atlas {
    key = 'conquest',
    path = 'Conquest.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'sprayon',
    atlas = 'sprayon',
    loc_txt = {
        name = 'Spray-On Joker',
        text = { 'Gain {C:mult}+#1#{} Mult when',
            'buying a {C:attention}Joker',
            '{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)' } },
    cost = 4,
    rarity = 1,
    discovered = true,
    perishable_compat = false,
    blueprint_compat = true,
    config = { extra = { mult = 0, mult_gain = 3 } },
    loc_vars = function(card, info_queue, center)
        return {
            vars = {
                center.ability.extra.mult_gain,
                center.ability.extra.mult
            }
        }
    end,
    calculate = function(card, card, context)
        if context.buying_card and not context.blueprint then
            if context.card.config.center.set == 'Joker' then
                card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
                return {
                    message = localize('k_upgrade_ex'), colour = G.C.MULT
                }
            end
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
}

SMODS.Atlas {
    key = 'sprayon',
    path = 'Spray-On_Joker.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'starving',
    atlas = 'starving',
    rarity = 2,
    cost = 6,
    discovered = true,
    blueprint_compat = true,
    loc_txt = { name = 'Starving Joker',
        text = { '{C:white,X:mult}X#1#{} Mult for each {C:spades}Spade',
            '{C:attention}face{} card in deck, {C:attention}destroys',
            '{C:spades}Spade{C:attention} face{} cards when scored',
            '{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult)' } },
    loc_vars = function(card, info_queue, center)
        if G.playing_cards ~= nil then
            local count = 0
            for i, v in ipairs(G.playing_cards) do
                if v:is_face() == true and v.base.suit == 'Spades' then
                    count = count + 1
                end
            end
            return {
                vars = {
                    center.ability.extra.offset,
                    1 + (count * center.ability.extra.offset)
                }
            }
        else
            return {
                vars = {
                    'nothing...',
                    'starving...'
                }
            }
        end
    end,
    config = { extra = { Xmult = 1, offset = 0.5 } },
    calculate = function(card, card, context)
        if context.joker_main then
            local count = 0
            for i, v in ipairs(G.playing_cards) do
                if v:is_face() == true and v.base.suit == 'Spades' then
                    count = count + 1
                end
            end
            card.ability.extra.Xmult = 1 + count * card.ability.extra.offset
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
        if context.destroy_card and context.cardarea == G.play and not context.blueprint then
            if context.destroy_card:is_face() == true and context.destroy_card.base.suit == 'Spades' then
                return {
                    remove = true,
                    message = 'Death!'
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'starving',
    path = 'Starving_Joker.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'spectro',
    cost = 10,
    rarity = 2,
    discovered = true,
    atlas = 'spectro',
    blueprint_compat = true,
    loc_txt = { name = 'Spectromancer',
        text = {
            'On selecting a {C:attention}Blind,',
            '{C:attention}destroy{} all consumables and',
            '{C:attention}create{} a {C:spectral}Spectral{} card' } },
    calculate = function(card, card, context)
        if context.setting_blind and not context.blueprint then
            for i, v in ipairs(G.consumeables.cards) do
                v:start_dissolve()
            end
            SMODS.add_card({ set = 'Spectral', area = G.consumeables })
        end
        if context.setting_blind and context.blueprint then
            SMODS.add_card({ set = 'Spectral', area = G.consumeables })
        end
    end,
    draw = function(self, card, layer)
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end
}

SMODS.Atlas {
    key = 'spectro',
    path = 'Spectromancer.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'ghost',
    discovered = true,
    loc_txt = { name = 'Ghost Clown',
        text = {
            '{C:white,X:chips}X#1#{} Chips per {C:spectral}Spectral',
            'card used this run',
            '{C:inactive}(Currently {C:white,X:chips}X#2#{C:inactive} Chips)'
        } },
    atlas = 'ghost',
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    pos = { x = 1, y = 0 },
    soul_pos = { x = 0, y = 0,
        draw = function(card, scale_mod, rotate_mod)
            card.hover_tilt = card.hover_tilt * 1.5
            card.children.floating_sprite:draw_shader('hologram', nil, card.ARGS.send_to_shader, nil,
                card.children.center, 2 * scale_mod, 2 * rotate_mod)
            card.hover_tilt = card.hover_tilt / 1.5
        end
    },
    loc_vars = function(self, info_queue, center)
        local xchips = 1
        if G.GAME.consumeable_usage_total ~= nil and G.GAME.consumeable_usage_total.spectral ~= nil then
            xchips = 1 + (G.GAME.consumeable_usage_total.spectral * center.ability.extra.mod)
        end
        return {
            vars = {
                center.ability.extra.mod,
                xchips
            }
        }
    end,
    config = { extra = { Xchips = 1, mod = 0.75 } },
    draw = function(self, card, layer)
        card.children.center:draw_shader('booster', nil, card.ARGS.send_to_shader)
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.consumeable_usage_total ~= nil and G.GAME.consumeable_usage_total.spectral ~= nil then
                card.ability.extra.Xchips = 1 + (G.GAME.consumeable_usage_total.spectral * card.ability.extra.mod)
            end
            return {
                xchips = card.ability.extra.Xchips
            }
        end
        if context.using_consumeable and not context.blueprint then
            local set = context.consumeable.config.center.set
            if set == 'Spectral' then
                return {
                    message = 'X' .. card.ability.extra.Xchips, colour = G.C.CHIPS,
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'ghost',
    path = 'Ghost_Clown.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'conspirator',
    atlas = 'consp',
    blueprint_compat = false,
    discovered = true,
    loc_txt = {
        name = 'Conspirator',
        text = { 'All scored cards on the',
            '{C:attention}final hand{} of the round',
            'become {C:dark_edition}foil{} cards' } },
    cost = 3,
    rarity = 1,
    calculate = function(self, card, context)
        if context.before and G.GAME.current_round.hands_left == 0 then
            for i, v in ipairs(context.scoring_hand) do
                if not v.debuff then
                    v:set_edition('e_foil')
                end
            end
        end
    end
}

SMODS.Atlas {
    key = 'consp',
    path = 'Conspirator.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'herald',
    loc_txt = { name = 'The Herald',
        text = {
            'Requires {C:attention}2{} Joker Slots',
            'After {C:attention}#1# {C:inactive}(#2#/#1#){} rounds, sell for',
            'permanent {C:dark_edition}+1{} Joker slots'
        } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.req,
                center.ability.extra.held
            }
        }
    end,
    rarity = 3,
    cost = 6,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = false,
    atlas = 'herald',
    config = { extra = { held = 0, req = 4 } },
    update = function(self, card, dt)
        card.edition = nil
    end,
    add_to_deck = function(self, card)
        G.jokers.config.card_limit = G.jokers.config.card_limit - 1
    end,
    remove_from_deck = function(self, card)
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            card.ability.extra.held = card.ability.extra.held + 1
            local eval = function(card)
                return (card.ability.extra.held >= card.ability.extra.req)
            end
            juice_card_until(card, eval, true)
        end
        if context.selling_self then
            if card.ability.extra.held >= card.ability.extra.req then
                G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                return {
                    message = 'Accomodated!'
                }
            else
                return {
                    message = 'Dismissed!'
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'herald',
    path = 'The_Herald.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'shapes',
    atlas = 'shapes',
    blueprint_compat = false,
    loc_txt = { name = 'Its all Just Shapes',
        text = {
            '{C:attention}Face{} cards become',
            '{C:attention}Glass{} when scored'
        } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
    end,
    rarity = 1,
    discovered = true,
    cost = 4,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:is_face() then
                context.other_card:set_ability(G.P_CENTERS.m_glass, nil, true)
            end
        end
    end
}

SMODS.Atlas {
    key = 'shapes',
    path = 'its_all_just_shapes.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'mystery',
    atlas = 'gift',
    loc_txt = { name = 'Mystery Gift',
        text = { 'When selecting a {C:attention}Boss{} blind,',
            '{C:green}#1# in #2#{} chance to make a',
            '{C:rare}Rare{} or {C:uncommon}Uncommon {C:attention}Joker{}, else',
            'create {C:attention}Mr. Bones',
            '{C:inactive}(self destructs)' } },
    config = { extra = { odds = 2 } },
    rarity = 1,
    cost = 4,
    eternal_compat = false,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_mr_bones
        return {
            vars = {
                G.GAME.probabilities.normal,
                center.ability.extra.odds
            }
        }
    end,
    blueprint_compat = false,
    discovered = true,
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind.boss == true then
            if pseudorandom('mysterygift') < G.GAME.probabilities.normal / card.ability.extra.odds then
                SMODS.add_card({
                    set = 'Joker',
                    area = G.jokers,
                    rarity = pseudorandom_element({ "Rare", "Uncommon" },
                        pseudoseed("mysterygiftgen"))
                })
            else
                SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_mr_bones' })
            end
            card:start_dissolve()
        end
    end
}

SMODS.Atlas {
    key = 'gift',
    path = 'Mystery_Gift.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'basement',
    loc_txt = { name = 'The Basement',
        text = {
            'On defeating a {C:attention}Boss{} blind,',
            'create {C:attention}#1#{} fools {C:inactive}(space required)',
            'and earn {C:money}$#2#{}',
            '{C:inactive}(Increase payout by {C:money}$#3#{C:inactive} when defeating a Boss)' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_fool
        return {
            vars = {
                center.ability.extra.fools,
                center.ability.extra.dollars,
                center.ability.extra.dollar_inc
            }
        }
    end,
    atlas = 'basement',
    discovered = true,
    rarity = 2,
    blueprint_compat = false,
    cost = 7,
    config = { extra = { dollars = 0, dollar_inc = 5, fools = 2 } },
    calculate = function(self, card, context)
        if context.end_of_round and G.GAME.blind.boss == true and context.main_eval then
            card.ability.extra.dollars = card.ability.extra.dollars + card.ability.extra.dollar_inc
            for i = 1, card.ability.extra.fools do
                if #G.consumeables.cards < G.consumeables.config.card_limit then
                    SMODS.add_card({ set = 'Tarot', area = G.consumeables, key = 'c_fool' })
                end
            end
        end
    end,
    calc_dollar_bonus = function(self, card)
        local mon = card.ability.extra.dollars
        if G.GAME.blind.boss == true then
            return mon
        end
    end
}

SMODS.Atlas {
    key = 'basement',
    path = 'The_Basement.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'rarejoker',
    atlas = 'rarejoker',
    discovered = true,
    loc_txt = { name = 'Rare Joker',
        text = { '{C:white,X:mult}X#1#{} Mult' } },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.Xmult } }
    end,
    config = { extra = { Xmult = 2 } },
    rarity = 3,
    blueprint_compat = true,
    cost = 2,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Atlas {
    key = 'rarejoker',
    path = 'NotJoker.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'basics',
    atlas = 'basics',
    loc_txt = { name = 'Back to Basics',
        text = { '{C:white,X:mult}X#1#{} Mult,',
            'reduce by {C:white,X:mult}X#2#{} when using a',
            '{C:tarot}Tarot{} or {C:planet}Planet{} card',
            '{C:inactive}(Reset when buying a {C:attention}Voucher{C:inactive})' } },
    config = { extra = { Xmult = 5, loss = 0.5, reset = 5 } },
    rarity = 2,
    discovered = true,
    cost = 6,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.Xmult,
                center.ability.extra.loss
            }
        }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            local set = context.consumeable.config.center.set
            if (set == 'Tarot' or set == 'Planet') and card.ability.extra.Xmult > 1 then
                card.ability.extra.Xmult = card.ability.extra.Xmult - card.ability.extra.loss
                return {
                    message = '-X' .. card.ability.extra.loss, colour = G.C.RED,
                }
            end
        end
        if context.buying_card and context.card.config.center.set == 'Voucher' then
            card.ability.extra.Xmult = card.ability.extra.reset
            return {
                message = 'Reset!', colour = G.C.RED,
            }
        end
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Atlas {
    key = 'basics',
    path = 'Tallies.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'rules',
    atlas = 'rules',
    rarity = 1,
    cost = 3,
    discovered = true,
    loc_txt = { name = 'Rules Card',
        text = {
            'If only {C:attention}#1#{} card is played,',
            'it becomes a {C:attention}Stone{} card'
        } },
    config = { extra = { cards = 1 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
        return { vars = { center.ability.extra.cards } }
    end,
    calculate = function(self, card, context)
        if context.before and #G.play.cards == card.ability.extra.cards then
            G.play.cards[1]:set_ability(G.P_CENTERS.m_stone)
        end
    end
}

SMODS.Atlas {
    key = 'rules',
    path = 'Rules_Card.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'anticheat',
    cost = 4,
    atlas = 'anticheat',
    rarity = 1,
    discovered = true,
    loc_txt = { name = 'Anticheat',
        text = {
            '{C:green}#1# in #2#{} chance to do',
            'nothing, else {C:chips}+#3#{} Chips'
        } },
    config = { extra = { odds = 2, chips = 100 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                G.GAME.probabilities.normal,
                center.ability.extra.odds,
                center.ability.extra.chips
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if (pseudorandom('anticheat') < G.GAME.probabilities.normal / card.ability.extra.odds) then
                return {
                    message = localize('k_nope_ex')
                }
            else
                return {
                    message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } },
                    chip_mod = card.ability.extra.chips,
                    colour = G.C.CHIPS
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'anticheat',
    path = 'AntiCheat.png',
    px = 71,
    py = 95
}

SMODS.Consumable {
    key = 'amulet',
    atlas = 'amulet',
    loc_txt = { name = 'Amulet',
        text = { 'Trigger a {C:attention}Wheel of Fortune',
            'once for every {C:attention}Joker{} owned' } },
    discovered = true,
    cost = 4,
    set = 'Spectral',
    can_use = function(self, card)
        if #G.jokers.cards > 0 then
            for i, v in ipairs(G.jokers.cards) do
                if v.edition == nil then
                    return true
                end
            end
        end
    end,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_wheel_of_fortune
    end,
    config = { extra = { odds = 4 } },
    use = function(self, card)
        for i = 1, #SMODS.Edition:get_edition_cards(G.jokers, true) do
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    local editionless_jokers = SMODS.Edition:get_edition_cards(G.jokers, true)
                    local eligible_card = pseudorandom_element(editionless_jokers, pseudoseed("amulet"))
                    if pseudorandom('amulet') < G.GAME.probabilities.normal / card.ability.extra.odds then
                        local edition = poll_edition('wheel_of_fortune', nil, true, true)
                        eligible_card:set_edition(edition, true)
                        return true
                    else
                        SMODS.calculate_effect({ message = localize('k_nope_ex') }, eligible_card)
                        return true
                    end
                end
            }))
        end
    end
}

SMODS.Atlas {
    key = 'amulet',
    path = 'Amulet_Spectral.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'concertticket',
    atlas = 'concert',
    loc_txt = { name = 'Concert Ticket',
        text = {
            '{C:green}#1# in #2#{} chance to',
            'retrigger played {C:clubs}Clubs',
            'cards {C:attention}#3#{} time'
        } },
    cost = 5,
    discovered = true,
    rarity = 1,
    config = { extra = { reps = 1, odds = 2 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                G.GAME.probabilities.normal,
                center.ability.extra.odds,
                center.ability.extra.reps
            }
        }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition then
            if context.other_card.base.suit == 'Clubs' and
                pseudorandom('concticket') < G.GAME.probabilities.normal / card.ability.extra.odds then
                return {
                    repetitions = card.ability.extra.reps
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'concert',
    path = 'ConcertTicket.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'keycard',
    atlas = 'keycard',
    rarity = 1,
    cost = 4,
    discovered = true,
    blueprint_compat = true,
    config = { extra = { inc = 1 } },
    loc_txt = { name = 'Key Card',
        text = { 'Prevents {C:attention}Gold{} cards',
            'from being debuffed, playing',
            '{C:attention}Gold{} cards increases',
            'their payout by {C:money}$#1#' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return {
            vars = {
                center.ability.extra.inc
            }
        }
    end,
    calculate = function(self, card, context)
        if context.setting_blind or context.using_consumeable or G.GAME.blind.in_blind then
            for i, v in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(v, 'm_gold') then
                    v.debuff = false
                end
            end
        end
        if context.before then
            for i, v in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(v, 'm_gold') then
                    v.ability.h_dollars = v.ability.h_dollars + card.ability.extra.inc
                    return {
                        message = 'Inc. Payout!',
                        colour = G.C.MONEY,
                        message_card = card
                    }
                end
            end
        end
    end,
    in_pool = function(self, args)
        for k, v in ipairs(G.playing_cards) do
            if SMODS.has_enhancement(v, 'm_gold') then
                return true
            end
        end
        return false
    end,
}

SMODS.Atlas {
    key = 'keycard',
    path = 'KeyCard.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'crook',
    atlas = 'crook',
    loc_txt = { name = 'A Crook',
        text = { 'Clicking on any remaining card',
            'in your deck will {C:attention}draw{} it to your',
            '{C:attention}hand{}, lose {C:money}$#1#' } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.dollars
            }
        }
    end,
    discovered = true,
    rarity = 3,
    cost = 6,
    config = { extra = { dollars = 10 } },
    calculate = function(self, card, context)
        if context.deck_click and G.GAME.dollars >= 6 then
            local _card = context.deck_click
            if G.STATE == 1 then
                if _card.area.config.type == 'title' and _card.greyed ~= true then
                    local _true = nil
                    for i, v in ipairs(G.deck.cards) do
                        if v.playing_card == _card.playing_card then
                            _true = v
                        end
                    end
                    ease_dollars(-card.ability.extra.dollars)
                    draw_card(G.deck, G.hand, 1, 'up', true, _true, nil)
                    _card.greyed = true
                end
            elseif G.STATE == 999 then
                if _card.area.config.type == 'title' then
                    local _true = nil
                    for i, v in ipairs(G.deck.cards) do
                        if v.playing_card == _card.playing_card then
                            _true = v
                        end
                    end
                    if _true then
                        ease_dollars(-card.ability.extra.dollars)
                        draw_card(G.deck, G.hand, 1, 'up', true, _true, nil)
                    end
                end
            end
        end
    end
}

SMODS.Atlas {
    key = 'crook',
    path = 'Crook.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'luggage',
    atlas = 'luggage',
    rarity = 1,
    discovered = true,
    blueprint_compat = false,
    cost = 4,
    loc_txt = { name = 'Luggage Card',
        text = { 'If only {C:attention}one{} card is played,',
            'it becomes {C:attention}tagged{}.',
            'That card will {C:attention}always be drawn{} into',
            'your first hand during future blinds' } },
    loc_vars = function(self, info_queue, center)
        if G.GAME.luggage_card and G.playing_cards[1] then
            local _card
            for i, v in ipairs(G.playing_cards) do
                if v.sort_id == G.GAME.luggage_card then
                    _card = v
                end
            end
            local _CardArea = CardArea(0, 0, G.CARD_W, G.CARD_H * 1.1,
                { type = "title", card_limit = 1, highlighted_limit = 0 })
            local main_end = {
                { n = G.UIT.O, config = { object = _CardArea } }
            }
            local new_card = copy_card(_card)
            _CardArea:emplace(new_card)
            return {
                main_end = main_end
            }
        end
    end,
    remove_from_deck = function(self, card)
        local lug = SMODS.find_card('j_tac_luggage')
        if not lug[1] then
            G.GAME.luggage_card = nil
        end
    end,
    config = { extra = { drawn = false } },
    calculate = function(self, card, context)
        if context.before and #G.play.cards == 1 and not context.blueprint then
            return {
                message = 'Stored!', colour = G.C.ATTENTION
            }
        end
        if context.remove_playing_cards then
            for i, v in ipairs(context.removed) do
                if v.sort_id == G.GAME.luggage_card then
                    G.GAME.luggage_card = nil
                end
            end
        end
        if context.end_of_round then
            card.ability.extra.drawn = false
        end
        if context.first_hand_drawn or (context.no_hand_draw and G.hand.config.card_limit < 1) then
            if G.GAME.luggage_card and card.ability.extra.drawn == false then
                card.ability.extra.drawn = true
                local _card
                local found = false
                for i, v in ipairs(G.playing_cards) do
                    if v.sort_id == G.GAME.luggage_card then
                        _card = v
                    end
                end
                for i, v in ipairs(G.hand.cards) do
                    if v.sort_id == G.GAME.luggage_card then
                        found = true
                    end
                end

                if found == false then
                    draw_card(G.deck, G.hand, 1, 'up', true, _card, nil)
                    if G.hand.config.card_limit < 1 then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            func = function()
                                SMODS.calculate_context({
                                    first_hand_drawn = not G.GAME.current_round.any_hand_drawn and G.GAME.facing_blind,
                                    hand_drawn = G.GAME.facing_blind and SMODS.drawn_cards,
                                    other_drawn = not G.GAME.facing_blind and SMODS.drawn_cards
                                })
                                SMODS.drawn_cards = { _card }
                                if G.GAME.facing_blind then G.GAME.current_round.any_hand_drawn = true end
                                return true
                            end
                        }))
                    end
                end
            end
        end
    end
}

SMODS.Atlas {
    key = 'luggage',
    path = 'LuggageCard.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'memory',
    atlas = 'memory',
    loc_txt = { name = 'Memory Allocation',
        text = {
            '{C:attention}+#1#{} Joker Slots,',
            '{C:red}-#2#{} Hand Size' } },
    discovered = true,
    rarity = 2,
    cost = 6,
    config = { extra = { hand_minus = 2, slots = 2 } },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.slots, center.ability.extra.hand_minus } }
    end,
    add_to_deck = function(self, card)
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.slots
        G.hand:change_size(-card.ability.extra.hand_minus)
    end,
    remove_from_deck = function(self, card)
        G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.slots
        G.hand:change_size(card.ability.extra.hand_minus)
    end
}

SMODS.Atlas {
    key = 'memory',
    path = 'Memory_Allocation.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'chaos',
    rarity = 3,
    cost = 10,
    atlas = 'chaos',
    pos = { x = 1, y = 0 },
    soul_pos = { x = 0, y = 0 },
    loc_txt = { name = 'Chaos Theory',
        text = {
            'Sorts your deck by {C:attention}#1#',
            '{s:0.8,C:inactive}(changes each round)',
            'Deck is drawn in order, starting from',
            '#2# of {V:1}#3#',
            '{C:inactive,s:0.8}(changes each round)'
        } },
    loc_vars = function(self, info_queue, center)
        if G.GAME.current_round.chaos_card and G.GAME.current_round.chaos_sort then
            return {
                vars = {
                    G.GAME.current_round.chaos_sort,
                    G.GAME.current_round.chaos_card.base.value,
                    G.GAME.current_round.chaos_card.base.suit,
                    colours = { G.C.SUITS[G.GAME.current_round.chaos_card.base.suit] }
                }
            }
        else
            return {
                vars = {
                    'Suit',
                    'King',
                    'Hearts',
                    colours = { G.C.SUITS['Hearts'] }
                }
            }
        end
    end
}

SMODS.Atlas {
    key = 'chaos',
    path = 'Legendary_Chaos_Theory.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'algo',
    atlas = 'algo',
    rarity = 2,
    cost = 6,
    discovered = true,
    loc_txt = { name = 'Algorithm',
        text = { '{C:attention}Copies{} the effect of the most',
            'recently obtained {C:attention}Joker' } },
    config = { extra = { _card = nil, compat = false } },
    loc_vars = function(self, info_queue, center)
        local main_end
        if G.GAME.tac_algo_card then
            info_queue[#info_queue + 1] = G.P_CENTERS[G.GAME.tac_algo_card]
            local found = false
            for i, v in ipairs(G.jokers.cards) do
                if v.config.center.key == G.GAME.tac_algo_card then
                    center.ability.extra._card = v
                    found = true
                end
            end
            if found then
                if center.ability.extra._card.config.center.blueprint_compat then
                    center.ability.blueprint_compat_ui = 'Compatible'
                    center.ability.extra.compat = true
                else
                    center.ability.blueprint_compat_ui = 'Incompatible'
                    center.ability.extra.compat = false
                end
                main_end = {
                    {
                        n = G.UIT.C,
                        config = { align = "bm", minh = 0.4 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = {
                                    ref_table = center,
                                    align = "m",
                                    colour = center.ability.extra.compat and
                                        mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or
                                        mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8),
                                    r = 0.05,
                                    padding = 0.06
                                },
                                nodes = {
                                    { n = G.UIT.T, config = { text = ' ' .. center.ability.blueprint_compat_ui .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                                }
                            }
                        }
                    }
                }
            else
                G.GAME.tac_algo_card = nil
            end
        end
        return {
            main_end = main_end
        }
    end,
    calculate = function(self, card, context)
        if G.GAME.tac_algo_card then
            local found = false
            for i, v in ipairs(G.jokers.cards) do
                if v.config.center.key == G.GAME.tac_algo_card then
                    card.ability.extra._card = v
                    found = true
                end
            end
            if found then
                return SMODS.blueprint_effect(card, card.ability.extra._card, context)
            else
                G.GAME.tac_algo_card = nil
            end
        end
    end
}

SMODS.Atlas {
    key = 'algo',
    path = 'Algorithm.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'freezer',
    atlas = 'freezer',
    rarity = 2,
    cost = 6,
    discovered = true,
    blueprint_compat = true,
    loc_txt = { name = 'Freezer',
        text = { 'Obtains the effects of fully',
            'consumed {C:attention}Food Jokers' } },
    config = { extra = { mult = 0, Xmult = 1, chips = 0, hand_size = 0, ret = 0, ret_times = 1,
        michel = false, cav = false, ice = false, bean = false, ramen = false, seltzer = false, popcorn = false } },
    set_sprites = function(self, card, front)
        card.children.michel_floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h,
            G.ASSET_ATLAS["tac_freezer"], { x = 1, y = 0 })
        SMODS.draw_ignore_keys.michel_floating_sprite = true

        card.children.cav_floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["tac_freezer"],
            { x = 2, y = 0 })
        SMODS.draw_ignore_keys.cav_floating_sprite = true

        card.children.cream_floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS
            ["tac_freezer"], { x = 3, y = 0 })
        SMODS.draw_ignore_keys.cream_floating_sprite = true

        card.children.selt_floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["tac_freezer"],
            { x = 4, y = 0 })
        SMODS.draw_ignore_keys.selt_floating_sprite = true

        card.children.pop_floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["tac_freezer"],
            { x = 5, y = 0 })
        SMODS.draw_ignore_keys.pop_floating_sprite = true

        card.children.ram_floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["tac_freezer"],
            { x = 6, y = 0 })
        SMODS.draw_ignore_keys.ram_floating_sprite = true

        card.children.bean_floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["tac_freezer"],
            { x = 7, y = 0 })
        SMODS.draw_ignore_keys.bean_floating_sprite = true

        card.children.egg_floating_sprite = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS["tac_freezer"],
            { x = 8, y = 0 })
        SMODS.draw_ignore_keys.egg_floating_sprite = true
    end,
    draw = function(self, card, scale_mod, rotate_mod)
        if Tacky.config.extra_freezer then
            local scale_mod, rotate_mod = 0, 0

            if card.ability.extra.michel then
                Tac.createfloat(card, card.children.michel_floating_sprite, scale_mod, rotate_mod)
            end
            if card.ability.extra.cav then
                Tac.createfloat(card, card.children.cav_floating_sprite, scale_mod, rotate_mod)
            end
            if card.ability.extra.ice then
                Tac.createfloat(card, card.children.cream_floating_sprite, scale_mod, rotate_mod)
            end
            if card.ability.extra.seltzer then
                Tac.createfloat(card, card.children.selt_floating_sprite, scale_mod, rotate_mod)
            end
            if card.ability.extra.popcorn then
                Tac.createfloat(card, card.children.pop_floating_sprite, scale_mod, rotate_mod)
            end
            if card.ability.extra.ramen then
                Tac.createfloat(card, card.children.ram_floating_sprite, scale_mod, rotate_mod)
            end
            if card.ability.extra.bean then
                Tac.createfloat(card, card.children.bean_floating_sprite, scale_mod, rotate_mod)
            end
            local egg = SMODS.find_card('j_egg')
            if egg[1] then
                Tac.createfloat(card, card.children.egg_floating_sprite, scale_mod, rotate_mod)
            end
        end
    end,
    loc_vars = function(self, info_queue, center)
        local main_mult, main_Xmult, main_chips, main_size, main_ret
        if center.ability.extra.mult > 0 then
            main_mult = {
                n = G.UIT.R,
                config = { align = 'cm', padding = 0.03 },
                nodes = {
                    { n = G.UIT.T, config = { text = '+' .. center.ability.extra.mult, colour = G.C.MULT, scale = 0.32 } },
                    { n = G.UIT.T, config = { text = ' Mult', colour = G.C.UI.TEXT_DARK, scale = 0.32 } }
                }
            }
        end
        if center.ability.extra.Xmult > 1 then
            main_Xmult = {
                n = G.UIT.R,
                config = { align = 'cm' },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15 },
                        nodes = {
                            { n = G.UIT.T, config = { text = 'X' .. center.ability.extra.Xmult, colour = G.C.WHITE, scale = 0.32 } }
                        }
                    },

                    {
                        n = G.UIT.C,
                        config = { padding = 0.03 },
                        nodes = {
                            { n = G.UIT.T, config = { text = ' Mult', colour = G.C.UI.TEXT_DARK, scale = 0.32 } }
                        }
                    }
                }
            }
        end
        if center.ability.extra.chips > 0 then
            main_chips = {
                n = G.UIT.R,
                config = { align = 'cm', padding = 0.03 },
                nodes = {
                    { n = G.UIT.T, config = { text = '+' .. center.ability.extra.chips, colour = G.C.CHIPS, scale = 0.32 } },
                    { n = G.UIT.T, config = { text = ' Chips', colour = G.C.UI.TEXT_DARK, scale = 0.32 } }
                }
            }
        end
        if center.ability.extra.ret > 0 then
            main_ret = {
                n = G.UIT.C,
                config = {},
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = 'cm', padding = 0.03 },
                        nodes = {
                            { n = G.UIT.T, config = { text = 'Retrigger first ', colour = G.C.UI.TEXT_DARK, scale = 0.32 } },
                            { n = G.UIT.T, config = { text = center.ability.extra.ret, colour = G.C.FILTER, scale = 0.32 } }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = 'cm', padding = 0.03 },
                        nodes = {
                            { n = G.UIT.T, config = { text = 'played cards ', colour = G.C.UI.TEXT_DARK, scale = 0.32 } },
                            { n = G.UIT.T, config = { text = center.ability.extra.ret_times, colour = G.C.FILTER, scale = 0.32 } },
                            { n = G.UIT.T, config = { text = ' time', colour = G.C.UI.TEXT_DARK, scale = 0.32 } }
                        }
                    }
                }
            }
        end
        if center.ability.extra.hand_size > 0 then
            main_size = {
                n = G.UIT.R,
                config = { align = 'cm', padding = 0.03 },
                nodes = {
                    { n = G.UIT.T, config = { text = '+' .. center.ability.extra.hand_size, colour = G.C.FILTER, scale = 0.32 } },
                    { n = G.UIT.T, config = { text = ' Hand Size', colour = G.C.UI.TEXT_DARK, scale = 0.32 } }
                }
            }
        end
        local main_end = {
            {
                n = G.UIT.R,
                config = { align = "bm" },
                nodes = {
                    main_mult,
                    main_Xmult,
                    main_chips,
                    main_ret,
                    main_size
                }
            }
        }
        return { main_end = main_end }
    end,
    remove_from_deck = function(self, card)
        G.hand:change_size(-card.ability.extra.hand_size)
    end,
    calculate = function(self, card, context)
        if context.card_destroyed and context.destroyed_card.config.center.key == 'j_ice_cream' and not context.blueprint then
            card.ability.extra.chips = card.ability.extra.chips + 50
            card.ability.extra.ice = true
            return { message = '+' .. card.ability.extra.chips .. ' Chips', colour = G.C.CHIPS }
        elseif context.card_destroyed and context.destroyed_card.config.center.key == 'j_popcorn' and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + 10
            card.ability.extra.popcorn = true
            return { message = '+' .. card.ability.extra.mult .. ' Mult', colour = G.C.MULT }
        elseif context.card_destroyed and context.destroyed_card.config.center.key == 'j_selzer' and not context.blueprint then
            if card.ability.extra.ret < 5 then
                card.ability.extra.ret = card.ability.extra.ret + 1
                card.ability.extra.seltzer = true
                return { message = card.ability.extra.ret .. 'Retriggers', colour = G.C.ATTENTION }
            end
        elseif context.card_destroyed and context.destroyed_card.config.center.key == 'j_ramen' and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + 0.5
            card.ability.extra.ramen = true
            return { message = 'X' .. card.ability.extra.Xmult .. ' Mult', colour = G.C.MULT }
        elseif context.card_destroyed and context.destroyed_card.config.center.key == 'j_turtle_bean' and not context.blueprint then
            card.ability.extra.hand_size = card.ability.extra.hand_size + 1
            G.hand:change_size(1)
            card.ability.extra.bean = true
            return { message = '+' .. card.ability.extra.hand_size .. ' Hand Size', colour = G.C.ATTENTION }
        elseif context.card_destroyed and context.destroyed_card.config.center.key == 'j_gros_michel' and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + 10
            card.ability.extra.michel = true
            return { message = '+' .. card.ability.extra.mult .. ' Mult', colour = G.C.MULT }
        elseif context.card_destroyed and context.destroyed_card.config.center.key == 'j_cavendish' and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + 1
            card.ability.extra.cav = true
            return { message = 'X' .. card.ability.extra.Xmult .. ' Mult', colour = G.C.MULT }
        elseif context.egg_up and not context.blueprint then
            card.ability.extra_value = card.ability.extra_value + 3
            card:set_cost()
            return { message = localize('k_val_up'), colour = G.C.MONEY }
        end

        if context.joker_main then
            local mult = card.ability.extra.mult or 0
            local Xmult = card.ability.extra.Xmult or 1
            local chips = card.ability.extra.chips or 0
            return {
                mult = mult,
                Xmult = Xmult,
                chips = chips
            }
        end
        if context.cardarea == G.play and context.repetition then
            for i = 1, card.ability.extra.ret do
                if context.other_card == context.full_hand[i] then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = card.ability.extra.ret_times,
                        message_card = card
                    }
                end
            end
        end
    end
}

SMODS.Atlas {
    key = 'freezer',
    path = 'Freezer.png',
    px = 71,
    py = 95
}
