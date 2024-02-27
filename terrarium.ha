use fmt;
use strings;
use math;
use math::random;
use types::c;
use raylib::*;

export fn main() void = {
	RNG = random::init(15);
	fmt::println("fatcock")!;
	let handle = match (init_window(1280, 720, c::fromstr("auterrarium"))) {
		case null => {
			fmt::println("Open Window Failed")!;
		};
		case let v : *opaque => v;
	};

	let cammy = Bungus {
		texture = load_texture(c::fromstr("./imgs/bungus1.png")),
		pos = Vector2 { x = 0.0, y = -30.0 },
		tex_off = Vector2 { x = 210.0, y = 160.0 },
		wiggle = 90.0,
		walk = 0.0,
		flip = false,
		goal = (0, 100) : Wait,
	};

	let savannah = Bungus {
		texture = load_texture(c::fromstr("./imgs/bungus2.png")),
		pos = Vector2 { x = -350.0, y = -150.0 },
		tex_off = Vector2 { x = 210.0, y = 160.0 },
		wiggle = 90.0,
		walk = 0.0,
		flip = false,
		goal = (0, 100) : Wait,
	};

	let lince = Bungus {
		texture = load_texture(c::fromstr("./imgs/bungus3.png")),
		pos = Vector2 { x =  350.0, y = -150.0 },
		tex_off = Vector2 { x = 210.0, y = 160.0 },
		wiggle = 1440.0,
		walk = 0.0,//20.0,
		flip = false,
		goal = (0, 100) : Wait,
	};

	let bungi = [&cammy, &savannah, &lince];

	start_goal(&cammy, (0, 100) : Wait);
	start_goal(&savannah, (0, 50) : Wait);
	start_goal(&lince, (0, 75) : Wait);
	let bg = load_texture(c::fromstr("./imgs/terrariumbg.png"));
	set_target_fps(25);
	for (!window_should_close()) {
		if (is_mouse_button_pressed(0)||is_mouse_button_pressed(0)) {
			fmt::println("TAP TAP TAP", get_mouse_x() - 640)!;
		for (let i : size = 0; i < len(bungi); i+= 1) {
			let cx = get_mouse_x() : f32 - 640.0;
			let bingus = bungi[i];
			let delta = bingus.pos.x - cx;
			fmt::println("bingus delta:", delta)!;
			let dir = math::signf32(delta) : f32;
			fmt::println("\tbingus direction:", dir)!;
			let tx : f32 = 500.0 * dir;
			fmt::println("\tbingus whoom:", tx)!;

			start_goal(bingus,
				Vector2 { x = tx, y = bingus.pos.y } : MoveTo
			);
		};
		};

		// sort them by y (because of lazyness
		for (let c1 : size = 0; c1 < len(bungi); c1 += 1) // guards next
		for (let i : size = 0; i + 1 < len(bungi); i += 1) {
			if (bungi[i].pos.y > bungi[i+1].pos.y) {
				continue;
			};
			let tmp = bungi[i];
			bungi[i] = bungi[i + 1];
			bungi[i + 1] = tmp;
		};

		begin_drawing();
		clear_background(COLOR_RAYWHITE);
		
		draw_texture_pro(bg,
			Rectangle
//				{ x = 0.0, y = 0.0, width = bg.width: f32, height = bg.height: f32 },
				{ x = bg.width: f32, y = 0.0, width = -bg.width: f32, height = bg.height: f32 },
			Rectangle
				{ x = 0.0, y = 0.0, width = 1280.0, height = 720.0},
			vector2_zero(),
			0.0,
			COLOR_WHITE,
		);

		for (let i : size = 0; i < len(bungi); i += 1) {
			draw_bungus(bungi[i]);
			//draw_bungus_goal(bungi[i]);
		};

		end_drawing();
		for (let i : size = 0; i < len(bungi); i += 1) {
			update_bungus(bungi[i]);
		};
	};

	for (let i : size = 0; i < len(bungi); i += 1) {
		unload_texture(bungi[i].texture);
	};
	unload_texture(bg);
};

let RNG = 0 : random::random;

type Bungus = struct {
	texture: Texture,
	pos: Vector2,
	tex_off: Vector2,
	wiggle: f32,
	walk: f32,
	flip: bool,
	goal: Goal,
};

fn draw_bungus(bingus: *Bungus) void = {
	// getting screen coords and center
	let x =  bingus.pos.x : int + 640; let ox = x;
	let y = -bingus.pos.y : int + 360; let oy = y;
		
	y += (math::cosf64(get_time() * 18.0) : f32 * bingus.walk): int;

	let out = Rectangle {
		x = x: f32, y = y: f32,
		width = bingus.texture.width: f32,
		height = bingus.texture.height: f32
	};

	let src = if ( bingus.flip) Rectangle {
		x = bingus.texture.width: f32, y = 0.0,
		width  = -bingus.texture.width : f32,
		height = bingus.texture.height : f32,
	} else Rectangle {
		x = 0.0, y = 0.0,
		width  = bingus.texture.width : f32,
		height = bingus.texture.height : f32,
	};
	
	let centrv = vector2_add(vector2_zero(), bingus.tex_off);
	let wob = math::sinf64(get_time() * 3.0) : f32 * bingus.wiggle;
	draw_texture_pro(bingus.texture, src, out, centrv, wob, COLOR_WHITE);
	//draw_bungus_goal(bingus);
};

fn start_goal(bingus: *Bungus, goal: Goal) void = {
	bingus.goal = goal;
	// bingus.flip = !bingus.flip;
	if (goal is Wait) {
		bingus.wiggle = 10.0;
	} else {
		bingus.wiggle = 0.0;
	};
	if (goal is MoveTo) {
		bingus.walk = 10.0;
		let move = goal as MoveTo;
		bingus.flip = (move.x > bingus.pos.x);
	} else {
		bingus.walk = 0.0;
	};
};

fn update_bungus(bingus: *Bungus) void = {
	if (bingus.goal is Wait) {
		let wait = bingus.goal as Wait;
		if (wait.0 >= wait.1) {
			start_goal(bingus, get_next(bingus.goal));
			return;
		};
		wait.0 += 1;
		bingus.goal = wait;
	} else if (bingus.goal is MoveTo) {
		let move = bingus.goal as MoveTo;
		if (vector2_equals(bingus.pos, move)) {
			start_goal(bingus, get_next(bingus.goal));
			return;
		};
		bingus.pos = vector2_move_towards(bingus.pos, move, 10.0);
	};

};

type Goal = (Wait|MoveTo);
type Wait = (u16, u16);
type MoveTo = Vector2;

fn get_next(goal: Goal) Goal = {
	match (goal) {
		case let w : Wait => { // Don't wait
			if (random::u32n(&RNG, 4) < 2) {
				let rt = (math::random::next(&RNG) & 0x01ff) : u16;
				return (0, rt): Wait;
			};
			let x = random::u32n(&RNG, 1280) : int - 640;
			let y = - random::u32n(&RNG, 360) : int;
			return Vector2 { x = x:f32, y = y:f32 } : MoveTo;
		};
		case let w : MoveTo => { // Wait
			let rt = (math::random::next(&RNG): u16 & 0x007fu16);
			return (0, rt): Wait;
		};
	};
};

fn draw_bungus_goal(bingus: *Bungus) void = {
	let buff : []u8 = alloc([0]:[]u8, 256);
	for (let i = 0; i < 256; i += 1) append(buff, 0);
	defer free(buff);
	// ...
	// ...
	match (bingus.goal) {
		case let wait : Wait => {
			fmt::bsprintf(buff, "{}/{}", wait.0, wait.1);
		};
		case let move : MoveTo => {
			fmt::bsprintf(buff, "moving to ({}, {})",
				move.x: int, move.y: int);
		};
	};
	
	let out = strings::fromutf8_unsafe(buff);
	let width = measure_text(c::fromstr(out), 50) / 2;
	let y = (-bingus.pos.y:int + 360) - 100;
	let x = bingus.pos.x: int + width;
	draw_text(c::fromstr(out), x, y, 50, COLOR_RED);
};
