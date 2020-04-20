require "loader";
require "utils";

CScreen = require("libs.CScreen")
tween = require("libs.tween")
inspect = require("libs.inspect")

Entity = require("src.entity");
Trap = require("src.trap");

-- States
require("src.game");
require("src.menu");

WIDTH = 1280;
HEIGHT = 720;

TILE_SIZE = 32;
TILE_SCALE = 2;

TILE_ABS_SIZE = TILE_SIZE * TILE_SCALE;

MAP_WIDTH  = 19;
MAP_HEIGHT = 9;

grid_x, grid_y = 0, 0;
mouse_x, mouse_y = 0, 0;

-- Colors
BLACK = 0x303030;

DONT_UPDATE = false;

local overlay_size_offset = 0;
local overlay_size_offset_target = 0;

local flashlight_force = 4;

state = Menu;

function project_absolute(x, y)
    -- return
    -- x * TILE_ABS_SIZE + (WIDTH/2  - TILE_ABS_SIZE/2),
    -- y * TILE_ABS_SIZE + (HEIGHT/2 - TILE_ABS_SIZE/2);
    return WIDTH/2 - TILE_ABS_SIZE/2 + TILE_ABS_SIZE * x, HEIGHT/2 - TILE_ABS_SIZE/2 + TILE_ABS_SIZE*y;
end

function project_relative(x, y)
    return
        math.floor((x - WIDTH/2 + TILE_ABS_SIZE/2)/TILE_ABS_SIZE),
        math.floor((y - HEIGHT/2 + TILE_ABS_SIZE/2)/TILE_ABS_SIZE);
end

function project_matrix(x, y)
    return x + 10, y + 6;
end

function love.load()
    load_assets();

    state:init();

    CScreen.init(1280, 720, true);
end

function love.draw()

    hex_color_bg(BLACK);
    CScreen.apply();

    state:draw();
    -- love.graphics.clear(1, 0, 0)
    -- love.graphics.rectangle("fill", 100, 100, 100, 100);
    -- love.graphics.draw(images.tile, 1280/2, 720/2, 0, 4, 4, 16, 16);
    -- love.graphics.draw(images.tile, 1280/2 + 32 * 4, 720/2, 0, 4, 4, 16, 16);
    -- love.graphics.draw(images.map, WIDTH/2, HEIGHT/2, 0, TILE_SCALE*2, TILE_SCALE*2, 337/2, 192/2)
    -- -- hex_color(BLACK, math.random(50, 80)/100);
    -- -- love.graphics.draw(images.overlay, WIDTH/2, HEIGHT/2, 0, TILE_SCALE*2 + overlay_size_offset, TILE_SCALE*2 + overlay_size_offset, 496/2, 288/2);
    -- hex_color(0xFFFFFF);
    -- for i=0,4 do
    --     for j=0,9 do
    --         love.graphics.setColor(i*.5, 0, j*.1, .4);
    --         local x, y = project_absolute(j, i);
    --         love.graphics.rectangle("fill", x, y, TILE_ABS_SIZE, TILE_ABS_SIZE);
    --         x, y = project_absolute(j, -i);
    --         love.graphics.rectangle("fill", x, y, TILE_ABS_SIZE, TILE_ABS_SIZE);
    --         x, y = project_absolute(-j, i);
    --         love.graphics.rectangle("fill", x, y, TILE_ABS_SIZE, TILE_ABS_SIZE);
    --         x, y = project_absolute(-j, -i);
    --     end
    -- end
    love.graphics.setColor(1, 1, 1);
    
    -- hex_color(0xFFFFFF, .5);
    -- local mouse_x_abs, mouse_y_abs = project_absolute(grid_x, grid_y);
    -- love.graphics.rectangle("fill", mouse_x_abs, mouse_y_abs, TILE_ABS_SIZE, TILE_ABS_SIZE);

    -- if not entity2 then
    --     entity2 = Entity.new();
    -- end
    -- entity2:draw();

    -- -- love.graphics.setColor(1, 1, 1, 0);
    -- shaders.flashlight:send("force", flashlight_force);
    -- love.graphics.setShader(shaders.flashlight);
    -- love.graphics.draw(images.pixel, 0, 0, 0, WIDTH, HEIGHT);
    -- love.graphics.setShader();

    -- love.graphics.print("Points: 23", 0, 0, 0, 4, 4);
    -- x, y = project_absolute(0, 1);
    -- love.graphics.rectangle("fill", x, y, TILE_ABS_SIZE, TILE_ABS_SIZE);
    CScreen.cease();
end

function love.update(dt)
    if not DONT_UPDATE then
        mouse_x, mouse_y = CScreen.project(love.mouse.getX(), love.mouse.getY());
        grid_x, grid_y = project_relative(mouse_x, mouse_y);
    end

    -- overlay_size_offset_target = math.random(1, 2);
    -- overlay_size_offset = lerp(overlay_size_offset, overlay_size_offset_target, 1/16);

    -- flashlight_force = lerp(flashlight_force, 4 + math.random(5)*math.random(-1, 1), dt)

    state:update(dt);

    -- if entity2 then
    --     entity2:update(dt);
    -- end
end

KEYS = {};

function love.keypressed(key)
    if key=="escape" then
        love.event.quit();
    end

    if key=="f" and Game.death then
        Game:restart();
    end

    KEYS[key] = true;

    if KEYS["lalt"] and KEYS["return"] then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
    -- Game:turn();
    -- entity2:jump(1,4);
end

function love.keyreleased(key)
    KEYS[key] = false;
end

function love.mousepressed()
    state:click();
end

function love.resize(w, h)
    CScreen.update(w, h);
end