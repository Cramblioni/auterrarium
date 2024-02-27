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
		pos = Vector2 { x = 640.0, y = 390.0 },
		wiggle = 90.0,
		walk = 0.0,
		flip = false,

		task = Mill,
		goal = (0, 100) : Wait,

		stats = new_init_stats(),
	};

	let savannah = Bungus {
		texture = load_texture(c::fromstr("./imgs/bungus2.png")),
		pos = Vector2 { x = 290.0, y = 510.0 },
		wiggle = 90.0,
		walk = 0.0,
		flip = false,

		task = Mill,
		goal = (0, 100) : Wait,

		stats = new_init_stats(),
	};

	let lince = Bungus {
		texture = load_texture(c::fromstr("./imgs/bungus3.png")),
		pos = Vector2 { x =  990.0, y = 540.0 },
		wiggle = 1440.0,
		walk = 0.0,//20.0,
		flip = false,

		task = Judge,
		goal = (0, 100) : Wait,

		stats = new_init_stats(),
	};

	let bungi = [&cammy, &savannah, &lince];

	let context = Context {
		bungi = bungi,
		water = Vector2 { x = 1210.0, y = 620.0 },
		food = [],
	};

	let falling : []Falling = [];

	set_task(&context, &cammy, Mill);
	set_task(&context, &savannah, Mill);
	set_task(&context, &lince, Mill);

	TEXT_BURGER = load_texture(c::fromstr("./imgs/burger.png"));
	let bg = load_texture(c::fromstr("./imgs/terrariumbg.png"));

	set_target_fps(25);
	for (!window_should_close()) {
		if (is_mouse_button_pressed(0)||is_mouse_button_pressed(1)) // GUARD
		for (let i : size = 0; i < len(bungi); i+= 1) {
			set_task(&context, bungi[i], Run);
		};

		// sort them by y (because of lazyness
		for (let c1 : size = 0; c1 < len(bungi); c1 += 1) // guards next
		for (let i : size = 0; i + 1 < len(bungi); i += 1) {
			if (bungi[i].pos.y < bungi[i+1].pos.y) {
				continue;
			};
			let tmp = bungi[i];
			bungi[i] = bungi[i + 1];
			bungi[i + 1] = tmp;
		};
		for (let c1 : size = 0; c1 < len(context.food); c1 += 1) // guards next
		for (let i : size = 0; i + 1 < len(context.food); i += 1) {
			if (context.food[i].pos.y < context.food[i].pos.y) {
				continue;
			};
			let tmp = context.food[i];
			context.food[i] = context.food[i + 1];
			context.food[i + 1] = tmp;
		};
		for (let c1 : size = 0; c1 < len(falling); c1 += 1) // guards next
		for (let i : size = 0; i + 1 < len(falling); i += 1) {
			if (falling[i].targ.y < falling[i].targ.y) {
				continue;
			};
			let tmp = context.food[i];
			context.food[i] = context.food[i + 1];
			context.food[i + 1] = tmp;
		};

		if (is_key_pressed(KEY_SPACE)) {
			let n = random::u32n(&RNG, 4) : int + 1;
			for (let i = 0; i < n; i += 1) {
				let x = (random::u32n(&RNG, 20) * 25 + 370) : f32;
				let y = (random::u32n(&RNG, 20) * 10 + 360) : f32;

				let new = Falling { 
					pos  = Vector2 { x = x, y = -100.0 },
					targ = Vector2 { x = x, y = y },
					roff = (random::u32n(&RNG, 3) : f32 - 1.5) * 10.0,
				};
				append(falling, new);
			};
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
			draw_bungus_goal(bungi[i]);
		};
		for (let i : size = 0; i < len(falling); i += 1) {
			let falls = &falling[i];
			let as_food = Food {
				pos = falls.pos,
				rot = math::sinf64(get_time()) : f32 * 20.0 + falls.roff,
				claimed = false, 
			};
			draw_food(&as_food);
		};
		for (let i : size = 0; i < len(context.food); i += 1) {
			draw_food(context.food[i]);
		};

		draw_fps(10, 10);
		end_drawing();
		for (let i : size = 0; i < len(bungi); i += 1) {
			update_bungus(&context, bungi[i]);
		};
		
		for (let i : size = 0; i < len(falling); i += 1) {
			let falls = &falling[i];
			falls.pos = vector2_move_towards(
				falls.pos, falls.targ,
				20.0
			);
			if (!vector2_equals(falls.pos, falls.targ)) {
				continue;
			};
			let falls = falling[i];
			falling[i] = falling[len(falling) - 1];
			delete(falling[len(falling) - 1]);	
			let as_food = Food {
				pos = falls.pos,
				rot = math::sinf64(get_time()) : f32 * 20.0 + falls.roff,
				claimed = false,
			};
			append(context.food, alloc(as_food));
		};
	};

	for (let i : size = 0; i < len(bungi); i += 1) {
		unload_texture(bungi[i].texture);
	};
	unload_texture(TEXT_BURGER);
	unload_texture(bg);
	close_window();
};

type Context = struct {
	bungi: []*Bungus,
	water: Vector2,
	food: []*Food,
};

let RNG = 0 : random::random;
let TEXT_BURGER = Texture { ... };
const COLOR_JUDGE = Color { r = 0xff, g = 0x7f, b = 0x7f, a = 0xff };
const COLOR_RUN   = Color { r = 0x7f, g = 0x7f, b = 0xff, a = 0xff };

type Bungus = struct {
	texture: Texture,
	pos: Vector2,
	wiggle: f32,
	walk: f32,
	flip: bool,

	task: Task,
	goal: Goal,
	
	stats: Stats,
};

type Stats = struct {
	food: int,
	water: int,
};
fn new_init_stats() Stats = Stats { food = 100, water = 100 };

fn stats_change_water(stats: *Stats, water: int) void = {
	stats.water += water;
	if (stats.water >  100) stats.water =  100;
	if (stats.water < -100) stats.water = -100;
};
fn stats_change_food(stats: *Stats, food: int) void = {
	stats.food += food;
	if (stats.food >  100) stats.food =  100;
	if (stats.food < -100) stats.food = -100;
};

fn draw_bungus(bingus: *Bungus) void = {
	// getting screen coords and center
	let x = bingus.pos.x : int;// bingus.pos.x : int + 640; let ox = x;
	let y = bingus.pos.y : int;// -bingus.pos.y : int + 360; let oy = y;
		
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
	
	//let centrv = vector2_add(vector2_zero(), bingus.tex_off);
	let centrv = Vector2 {
		x = bingus.texture.width : f32,
		y = bingus.texture.height : f32
	}; 
	centrv = vector2_scale(centrv, 0.5);
	let wob = math::sinf64(get_time() * 3.0) : f32 * bingus.wiggle;
	let tint = if (bingus.task is Judge) COLOR_JUDGE
		else if (bingus.task is Run) COLOR_RUN
		else COLOR_WHITE;
	draw_texture_pro(bingus.texture, src, out, centrv, wob, tint);
};

fn start_goal(context: *Context, bingus: *Bungus, goal: Goal) void = {
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

fn update_bungus(context: *Context, bingus: *Bungus) void = {
	make_decisions(context, bingus);
	do_stuff(context, bingus);
};
fn make_decisions(context: *Context, bingus: *Bungus) void = {
	if (random::u32n(&RNG, 4) < 1) // GUARD
		stats_change_food(&bingus.stats, -1);
	if (random::u32n(&RNG, 4) < 2) // GUARD
		stats_change_water(&bingus.stats, -1);
	if (bingus.task is Run) {
		let mp = Vector2 {
			x = get_mouse_x() : f32,
			y = get_mouse_y() : f32,
		};
		if (vector2_distance(mp, bingus.pos) < 500.0) {// * 150.0) {
			start_goal(context, bingus, get_next(context, bingus));
			return;
		};
		set_task(context, bingus, Mill);
	};
	if (bingus.stats.food <= -90) { // Hungry
		if (bingus.task is Judge || bingus.task is Eat)
			yield;
		if (len(context.food) == 0) // GUARD
			set_task(context, bingus, Judge)
		else
			set_task(context, bingus, Eat);
	};
	if (bingus.stats.water <= -40) { // Thirsty
		if (bingus.task is Judge || bingus.task is Drink)
			yield;
		set_task(context, bingus, Drink);
		start_goal(context, bingus, get_next(context, bingus));
	};
};
fn do_stuff(context: *Context, bingus: *Bungus) void = {
	if (bingus.goal is Wait) {
		let wait = bingus.goal as Wait;
		if (wait.0 >= wait.1) {
			start_goal(context, bingus, get_next(context, bingus));
			return;
		};
		wait.0 += 1;
		bingus.goal = wait;
	} else if (bingus.goal is MoveTo) {
		let move = bingus.goal as MoveTo;
		if (vector2_equals(bingus.pos, move)) {
			start_goal(context, bingus, get_next(context, bingus));
			return;
		};
		bingus.pos = vector2_move_towards(bingus.pos, move, 10.0);
	} else {
		yield;
	};
};

type Goal = (Wait|MoveTo);
type Wait = (u16, u16);
type MoveTo = Vector2;

fn get_next(context: *Context, bingus: *Bungus) Goal = {
	let ret = bingus.goal;
	match (bingus.task) {
		case let m : Mill  => ret = get_next_mill(context, bingus, bingus.goal);
		case let m : Eat   => ret = get_next_eat(context, bingus, bingus.goal);
		case let m : Drink => ret = get_next_drink(context, bingus, bingus.goal);
		case let m : Run   => ret = get_next_run(context, bingus, bingus.goal);
		case let m : Judge => ret = get_next_judge(context, bingus, bingus.goal);
	};
	return ret;
};
fn get_next_mill(context: *Context, bingus: *Bungus, goal: Goal) Goal = {
	match (goal) {
		case let w : Wait => { // Don't wait
			if (random::u32n(&RNG, 4) < 2) {
				let rt = (math::random::next(&RNG) & 0x01ff) : u16;
				return (0, rt): Wait;
			};
			let x = random::u32n(&RNG, 1000) : int + 140;
			let y = random::u32n(&RNG, 330) : int + 375;
			return Vector2 { x = x:f32, y = y:f32 } : MoveTo;
		};
		case let w : MoveTo => { // Wait
			let rt = (math::random::next(&RNG): u16 & 0x01ffu16);
			return (0, rt): Wait;
		};
	};
};

fn get_next_eat(context: *Context, bingus: *Bungus, goal: Goal) Goal = {
	return goal;
};

fn get_next_judge(context: *Context, bingus: *Bungus, goal: Goal) Goal = {
	if (len(context.food) > 0) {
		set_task(context, bingus, Eat);
		return get_next_eat(context, bingus, goal);
	};
	match (goal) {
		case let w : Wait => { // Don't wait
			if (random::u32n(&RNG, 4) < 2) {
				let rt = (math::random::next(&RNG) & 0x003f) : u16;
				return (0, rt): Wait;
			};
			let x = random::u32n(&RNG, 500) : int + 390;
			let y = random::u32n(&RNG, 300) : int + 350;
			return Vector2 { x = x:f32, y = y:f32 } : MoveTo;
		};
		case let w : MoveTo => { // Wait
			let rt = (math::random::next(&RNG): u16 & 0x003fu16);
			return (0, rt): Wait;
		};
	};
};

fn get_next_run(context: *Context, bingus: *Bungus, goal: Goal) Goal = {
	let mp = Vector2 {
		x = get_mouse_x() : f32,
		y = get_mouse_y() : f32,
	};
	// calculate a point away from the cursor
	// And then GOTO it
	let off = Vector2 {
		x = (random::u32n(&RNG, 10) : int - 5) : f32,
		y = (random::u32n(&RNG, 10) : int - 5) : f32,
	};
	let d = vector2_subtract(bingus.pos, mp);
	d = vector2_normalize(d);
	d = vector2_add(vector2_scale(d, 150.0), off);
	let tp = vector2_add(bingus.pos, d);
	if (tp.x < 50.0 || tp.x > 1230.0) // GUARD
		d.x = 0.0;
	if (tp.y < 300.0 || tp.x > 670.0) // GUARD
		d.y = 0.0;
	tp = vector2_add(bingus.pos, d);
	return tp : MoveTo;
};

fn get_next_drink(context: *Context, bingus: *Bungus, goal: Goal) Goal = {
	if (vector2_distance(bingus.pos, context.water) > 50.0) {
		let off = Vector2 {
			x = (random::u32n(&RNG, 10) : int - 5) : f32,
			y = (random::u32n(&RNG, 10) : int - 5) : f32,
		};
		return vector2_add(context.water, off) : MoveTo;
	};
	stats_change_water(&bingus.stats, 150);
	return (0, 100) : Wait;
};

fn draw_bungus_goal(bingus: *Bungus) void = {
	let buff : []u8 = alloc([0]:[]u8, 256);
	for (let i = 0; i < 256; i += 1) append(buff, 0);
	defer free(buff);
	match (bingus.goal) {
		case let wait : Wait => {
			fmt::bsprintf(buff, "{}: waiting {}/{}",
				task_to_str(bingus.task),
				wait.0, wait.1);
		};
		case let move : MoveTo => {
			fmt::bsprintf(buff, "{}: moving to ({}, {})",
				task_to_str(bingus.task),
				move.x: int, move.y: int);
		};
	};
	
	let out = strings::fromutf8_unsafe(buff);
	let width = measure_text(c::fromstr(out), 50) / 2;
	let y = bingus.pos.y:int - 100;
	let x = bingus.pos.x: int - width / 2;
	draw_text(c::fromstr(out), x, y, 50, COLOR_RED);
};

type Task  = (Eat|Drink|Mill|Run|Judge);
type Eat   = void; // Eat some food
type Drink = void; // Have some drink
type Mill  = void; // Stand around and walk from point to point
type Run   = void; // Running away from the cursor
type Judge = void; // Go to the middle and judge the "player"

fn set_task(context: *Context, bingus: *Bungus, task: Task) void = {
	bingus.task = task;
	start_goal(context, bingus, get_next(context, bingus));
};

fn task_to_str(task: Task) const str = {
	return match (task) {
		case let t : Eat   => yield "eat"   ;
		case let t : Drink => yield "drink" ;
		case let t : Mill  => yield "mill"  ;
		case let t : Run   => yield "run"   ;
		case let t : Judge => yield "judge" ;
	};
};

type Food = struct {
	pos: Vector2,
	rot: f32,
	claimed: bool,
};

type Falling = struct {
	pos: Vector2,
	targ: Vector2,
	roff: f32,
};
fn draw_food(food: *Food) void = {
	let src = Rectangle {
		x = 0.0, y = 0.0,
		width  = TEXT_BURGER.width : f32,
		height = TEXT_BURGER.height : f32,
	};
	let centr = Vector2 {
		x = src.width * 0.5,
		y = src.height * 0.5,
	};
	let dest = src;
	dest.x = food.pos.x;
	dest.y = food.pos.y;

	draw_texture_pro(TEXT_BURGER,
		src,
		dest,
		centr,
		food.rot,
		COLOR_WHITE,
	);
};
