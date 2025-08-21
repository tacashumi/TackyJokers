SMODS.Challenge {
    key = 'capitalist',
    loc_txt = {name = 'Capitalist'},
    jokers = {
        {id = 'j_tac_crook', eternal = true, rental = true}
    },
    consumeables = {
        {id = 'c_talisman'}
    },
    restrictions = {
        banned_cards = {
            { id = 'j_raised_fist' },
            { id = 'j_ride_the_bus' },
            { id = 'j_burglar' },
            { id = 'j_vagabond' },
            { id = 'j_campfire' },
            { id = 'j_walkie_talkie' },
            { id = 'j_swashbuckler' }
        }}
}

SMODS.Challenge {
    key = 'ship_it',
    loc_txt = {name = 'Ship It!'},
    jokers = {
        {id = 'j_tac_luggage'},
        {id = 'j_tac_hacker'},
        {id = 'j_burglar', eternal = true}
    },
    rules = {
        custom = {
            { id = 'no_shop_jokers' },
        }
    }
}

SMODS.Challenge {
    key = 'particle',
    loc_txt = {name = 'Particle Accelerator'},
    jokers = {
        {id = 'j_tac_luggage', eternal = true},
        {id = 'j_perkeo', eternal = true}
    },
    consumeables = {
        {id = 'c_ectoplasm'}
    },
}

SMODS.Challenge {
    key = 'serene',
    loc_txt = {name = 'Serene Theory'},
    jokers = {
        {id = 'j_tac_chaos', eternal = true}
    },
    deck = {
        cards = {
            {s = 'S', r = 'K', e = 'm_stone'},
            {s = 'H', r = 'Q', e = 'm_stone'},
            {s = 'C', r = 'J', e = 'm_stone'},
            {s = 'D', r = 'T', e = 'm_stone'},
            {s = 'S', r = '9', e = 'm_stone'},
            {s = 'H', r = '8', e = 'm_stone'},
            {s = 'C', r = '7', e = 'm_stone'},
            {s = 'D', r = '6', e = 'm_stone'},
            {s = 'S', r = '5', e = 'm_stone'},
            {s = 'H', r = '4', e = 'm_stone'},
            {s = 'C', r = '3', e = 'm_stone'},
            {s = 'D', r = '2', e = 'm_stone'},
        }
    }
}

SMODS.Challenge {
    key = 'coolplace',
    loc_txt = {name = 'Store In A Cool Place'},
    jokers = {
        {id = 'j_tac_freezer', eternal = true},
        {id = 'j_madness', eternal = true}
    },
    rules = {
        modifiers = {
            {id = 'joker_slots', value = 3}
        }
    }
}