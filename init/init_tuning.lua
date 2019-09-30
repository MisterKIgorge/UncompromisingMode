
local seg_time = 30

local day_segs = 10
local dusk_segs = 4
local night_segs = 2

local day_time = seg_time * day_segs
local total_day_time = seg_time * 16

local day_time = seg_time * day_segs
local dusk_time = seg_time * dusk_segs
local night_time = seg_time * night_segs

TUNING = GLOBAL.TUNING

-- Stone fruit nerf x3 duration
TUNING.ROCK_FRUIT_REGROW =
{
    EMPTY = { BASE = 6*day_time, VAR = 2*seg_time },
    PREPICK = { BASE = 3*seg_time, VAR = 0 },
    PICK = { BASE = 9*day_time, VAR = 2*seg_time },
    CRUMBLE = { BASE = 3*day_time, VAR = 2*seg_time },
},