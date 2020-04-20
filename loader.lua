images = {};

fonts = {};

function load_assets()
    music = {
        theme = love.audio.newSource("assets/theme.ogg", "static");
        menu = love.audio.newSource("assets/theme_menu.ogg", "static");
    }
    music.theme:setLooping(true);
    music.menu:setLooping(true);
    for _,track in pairs(music) do
        track:setVolume(.5);
    end

    sfx = {
        coin = love.audio.newSource("assets/coin.wav", "static");
        jump = love.audio.newSource("assets/jump.wav", "static");
        hit  = love.audio.newSource("assets/hit.wav", "static");
        die  = love.audio.newSource("assets/die.wav", "static");
        player_death  = love.audio.newSource("assets/player_death.wav", "static");
        no  = love.audio.newSource("assets/no.wav", "static");
        select  = love.audio.newSource("assets/select.wav", "static");
    }
    for _,track in pairs(sfx) do
        track:setVolume(.5);
    end

    love.graphics.setDefaultFilter("nearest", "nearest");
    images = {
        tile = love.graphics.newImage("assets/tile.png"),
        atlas = love.graphics.newImage("assets/atlas.png"),
        overlay = love.graphics.newImage("assets/overlay.png"),
        map = love.graphics.newImage("assets/map.png"),
        pixel = love.graphics.newImage("assets/pixel.png"),
    };

    title = love.graphics.newQuad(0, 96, 86, 13, 320, 320);
    play1 = love.graphics.newQuad(0, 112, 32, 14, 320, 320);
    play2 = love.graphics.newQuad(0, 128, 34, 16, 320, 320);
    music_icon = love.graphics.newQuad(48, 48, 9, 8, 320, 320);
    sound_icon = love.graphics.newQuad(48 + 16, 48, 9, 8, 320, 320);

    monster_quads = {};
    traps = {};
    for i=0,20 do
        monster_quads[#monster_quads+1] = love.graphics.newQuad(16*i, 0, 16, 16, 320, 320);
        monster_quads[#monster_quads+1] = love.graphics.newQuad(16*i, 16*1, 16, 16, 320, 320);
        
        traps[#traps+1] = love.graphics.newQuad(16*i, 16*4, 16, 16, 320, 320);
    end
    particle = love.graphics.newQuad(16, 16*3, 2, 2, 320, 320);

    quads = {
        smoke = love.graphics.newQuad(0, 16*3, 16, 16, 320, 320),
    }

    fonts = {
        thicket = love.graphics.newFont("assets/ChevyRay - Thicket.ttf"),
    }

    love.graphics.setFont(fonts.thicket)

    shaders = {};

    shaders.flashlight = love.graphics.newShader([[
        uniform float force;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            float distance = pow(texture_coords.x - .5, 2) + pow(texture_coords.y - .5, 2);
            distance*=.9;
            if(mod(floor((texture_coords.x - texture_coords.y) * (100)), 2)==0){
                return vec4(0, 0, 0, min(.9, distance*force*.95));
            }else{
                return vec4(0, 0, 0, min(.9, distance*force));
            }
        }
    ]]);

    shaders.barrier = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            if(mod(floor((texture_coords.x - texture_coords.y) * 3), 2)==0){
                return color;
            }
            return color*.9;
        }
    ]]);

    shaders.outline = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec4 c = Texel(texture, texture_coords);

            if(c.a==0 &&
                (Texel(texture, texture_coords+vec2(  0.003, 0)).a!=0 ||
                Texel(texture, texture_coords-vec2(   0.003, 0)).a!=0 ||
                Texel(texture, texture_coords+vec2(0, 0.003)).a!=0 ||
                Texel(texture, texture_coords-vec2(0, 0.003)).a!=0)){
                c = color;
            }

            return c;
        }
    ]]);
end