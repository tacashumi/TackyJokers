Tac = {}

local cfbs = G.FUNCS.check_for_buy_space
function G.FUNCS.check_for_buy_space(card)
    if card.config.center.key == 'j_tac_herald' then
        local space = G.jokers.config.card_limit - #G.jokers.cards
        if space >= 2 then
            return true
        else
            alert_no_space(card, card.ability.consumeable and G.consumeables or G.jokers)
            return false
        end
    elseif card.config.center.key == 'j_tac_memory' then
        local space = G.jokers.config.card_limit - #G.jokers.cards
        if space >= -1 then
            return true
        else
            alert_no_space(card, card.ability.consumeable and G.consumeables or G.jokers)
            return false
        end
    else
        return cfbs(card)
    end
end

local csc = G.FUNCS.can_sell_card
function G.FUNCS.can_sell_card(card)
    if card.config.ref_table.config.center_key == 'j_tac_memory' and
        #G.jokers.cards >= G.jokers.config.card_limit then
        card.config.colour = G.C.UI.BACKGROUND_INACTIVE
        card.config.button = nil
    else
        return csc(card)
    end
end

function G.FUNCS.tac_crook_can(card)
    if G.GAME.blind and G.GAME.blind.in_blind and G.GAME.dollars >= (#G.deck.cards * 6) and #G.deck.cards > 0 and not card.debuff then
        card.config.colour = G.C.RED
        card.config.button = 'tac_crook_use'
    else
        card.config.colour = G.C.UI.BACKGROUND_INACTIVE
        card.config.button = nil
    end
end

function G.FUNCS.tac_crook_use(card)
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            ease_dollars(-(#G.deck.cards * 6))
            G.FUNCS.draw_from_deck_to_hand(#G.deck.cards)
            return true
        end
    }))
end

function G.FUNCS.tac_chaos_sort(list, cards)
    local start = 1
    for i, v in ipairs(cards) do
        if v.base.name == G.GAME.current_round.chaos_card.base.name then
            start = i
            break
        end
    end
    local count = #cards
    for i = start, #G.playing_cards do
        list[count] = cards[i]
        count = count - 1
    end
    for i = 1, start do
        list[count] = cards[i]
        count = count - 1
    end
end

local ps = pseudoshuffle
function pseudoshuffle(list, seed)
    local chaos = SMODS.find_card('j_tac_chaos')
    if chaos[1] then
        local suits = { 'Spades', 'Hearts', 'Clubs', 'Diamonds' }
        local ranks = {}
        local cards = {}
        for i = 14, 1, -1 do
            table.insert(ranks, i)
        end
        if G.GAME.current_round.chaos_sort == 'Suit' then
            for k, t in ipairs(suits) do
                for p, c in ipairs(ranks) do
                    for i, v in ipairs(G.playing_cards) do
                        if v.base.suit == t and v.base.id == c then
                            table.insert(cards, v)
                        end
                    end
                end
            end
            G.FUNCS.tac_chaos_sort(list, cards)
        elseif G.GAME.current_round.chaos_sort == 'Rank' then
            for k, t in ipairs(ranks) do
                for p, c in ipairs(suits) do
                    for i, v in ipairs(G.playing_cards) do
                        if v.base.id == t and v.base.suit == c then
                            table.insert(cards, v)
                        end
                    end
                end
            end
            G.FUNCS.tac_chaos_sort(list, cards)
        end
    else
        return ps(list, seed)
    end
end

local gcp = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    local _pool, _pool_key = gcp(_type, _rarity, _legendary, _append)
    if G.GAME.tacky_only == true and _type == 'Joker' then
        for i, v in ipairs(_pool) do
            if not (string.sub(v, 1, 5) == 'j_tac') then
                _pool[i] = 'UNAVAILABLE'
            end
        end
    end
    return _pool, _pool_key
end

local gsr = Game.start_run
function Game:start_run(args)
    local ret = gsr(self, args)
    if Tacky.config.tacky_only == true then
        self.GAME.tacky_only = true
    else
        self.GAME.tacky_only = false
    end
    return ret
end

function Tac.createfloat(card, name, scale_mod, rotate_mod)
    name:draw_shader('dissolve', nil, nil, nil, card.children.center, scale_mod, rotate_mod)
    name.role.draw_major = card
    name.states.hover.can = false
    name.states.click.can = false
end
