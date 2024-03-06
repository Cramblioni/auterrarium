use fmt;
use strings;
use math;
use math::random;
use types::c;
use raylib::*;

export fn main() void = {
	RNG = random::init(15);
	// We shouldn't exceed 256 sprites
	RENDER_QUEUE = alloc([]:[]*Sprite, 256); 
	fmt::println("fatcock")!;
	let handle = match (init_window(1280, 720, c::fromstr("auterrarium"))) {
		case null => {
			fmt::println("Open Window Failed")!;
		};
		case let v : *opaque => v;
	};

	let cammy = Bungus {
		sprite = add_sprite(&RENDER_QUEUE,
			load_sprite(c::fromstr("./imgs/bungus1.png"))),
		pos = Vector2 { x = 640.0, y = 390.0 },
		wiggle = 90.0,
		walk = 0.0,

		task = Mill,
		goal = (0, 100) : Wait,

		stats = new_init_stats(),
	};

	let savannah = Bungus {
		sprite = add_sprite(&RENDER_QUEUE,
			load_sprite(c::fromstr("./imgs/bungus2.png"))),
		pos = Vector2 { x = 290.0, y = 510.0 },
		wiggle = 90.0,
		walk = 0.0,

		task = Mill,
		goal = (0, 100) : Wait,

		stats = new_init_stats(),
	};

	let lince = Bungus {
		sprite = add_sprite(&RENDER_QUEUE,
			load_sprite(c::fromstr("./imgs/bungus3.png"))),
		pos = Vector2 { x =  990.0, y = 540.0 },
		wiggle = 1440.0,
		walk = 0.0,//20.0,

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

	// CAMERA = Camera3D {
	// 	position   = Vector3 { x = 640.0, y = 360.0, z = 500.0 },
	// 	target     = Vector3 { x =   0.0, y =   0.0, z =   0.0 },
	// 	up         = Vector3 { x =   0.0, y =   1.0, z =   0.0 },
	// 	fovy       = 45.0,
	// 	projection = 1 : Projection, // orthographic
	// };

	set_target_fps(25);
	for (!window_should_close()) {


		if (is_mouse_button_pressed(0)||is_mouse_button_pressed(1)) // GUARD
		for (let i : size = 0; i < len(bungi); i+= 1) {
			set_task(&context, bungi[i], Run);
		};

		// sort them by y (because of lazyness
		//for (let c1 : size = 0; c1 < len(bungi); c1 += 1) // guards next
		//for (let i : size = 0; i + 1 < len(bungi); i += 1) {
		//	if (bungi[i].pos.y < bungi[i+1].pos.y) {
		//		continue;
		//	};
		//	let tmp = bungi[i];
		//	bungi[i] = bungi[i + 1];
		//	bungi[i + 1] = tmp;
		//};
		//for (let c1 : size = 0; c1 < len(context.food); c1 += 1) // guards next
		//for (let i : size = 0; i + 1 < len(context.food); i += 1) {
		//	if (context.food[i].pos.y < context.food[i].pos.y) {
		//		continue;
		//	};
		//	let tmp = context.food[i];
		//	context.food[i] = context.food[i + 1];
		//	context.food[i + 1] = tmp;
		//};
		//for (let c1 : size = 0; c1 < len(falling); c1 += 1) // guards next
		//for (let i : size = 0; i + 1 < len(falling); i += 1) {
		//	if (falling[i].targ.y < falling[i].targ.y) {
		//		continue;
		//	};
		//	let tmp = context.food[i];
		//	context.food[i] = context.food[i + 1];
		//	context.food[i + 1] = tmp;
		//};

		if (is_key_pressed(KEY_SPACE)) {
			let n = random::u32n(&RNG, 4) : int + 1;
			for (let i = 0; i < n; i += 1) {
				sprinkle_food(&falling);
			};
		};

		begin_drawing();
		clear_background(COLOR_RAYWHITE);
		draw_texture_pro(bg,
			Rectangle
				{ x = bg.width: f32, y = 0.0, 
				  width = -bg.width: f32,
			          height = bg.height: f32 },
			Rectangle
				{ x = 0.0, y = 0.0,
				  width = 1280.0,
			          height = 720.0},
			vector2_zero(),
			0.0,
			COLOR_WHITE,
		);

		// for (let i : size = 0; i < len(context.food); i += 1) {
		//	draw_food(context.food[i]);
		//};
		sort_render_queue(&RENDER_QUEUE);
		for (let i : size = 0; i < len(RENDER_QUEUE); i += 1) {
			render_sprite(RENDER_QUEUE[i]);
		};

		// DEBUG
		for (let i : size = 0; i < len(bungi); i += 1) {
			draw_bungus_goal(bungi[i]);
		};
		draw_fps(10, 10);
		// DEBUG
		end_drawing();
		for (let i : size = 0; i < len(bungi); i += 1) {
			update_bungus(&context, bungi[i]);
		};
		
		for (let i : size = 0; i < len(falling); i += 1) {
			let falls = &falling[i];
			falls.sprite.pos = vector2_move_towards(
				falls.sprite.pos, falls.targ,
				20.0
			);
			falls.sprite.rot = math::sinf64(get_time() * 3.0) : f32
					 + falls.roff;
			if (!vector2_equals(falls.sprite.pos, falls.targ)) {
				continue;
			};
			let falls = falling[i];
			falling[i] = falling[len(falling) - 1];
			delete(falling[len(falling) - 1]);	
			let as_food = Food {
				sprite = falls.sprite,
				claimed = false,
			};
			append(context.food, alloc(as_food));
		};
	}; // END OF MAIN LOOP

	// Not removing them from the render queue,
	// As that is freed immediately after :)
	for (let i : size = 0; i < len(bungi); i += 1) {
		// remove_sprite(&RENDER_QUEUE, bungi[i].sprite);
		unload_texture(bungi[i].sprite.texture);
		free(bungi[i].sprite);
	};
	for (let i : size = 0; i < len(falling); i += 1) {
		// remove_sprite(&RENDER_QUEUE, falling[i].sprite);
		free(falling[i].sprite);
	};
	free(falling);
	for (let i : size = 0; i < len(context.food); i += 1) {
		// remove_sprite(&RENDER_QUEUE, context.food[i].sprite());
		free(context.food[i]);
	};
	free(context.food);
	free(RENDER_QUEUE);
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

let RENDER_QUEUE : []*Sprite = [];

type Bungus = struct {
	// rendering
	sprite: *Sprite,

	// modifying sprite
	pos: Vector2,
	wiggle: f32,
	walk: f32,

	// AI
	task: Task,
	goal: Goal,
	
	// Purpose in life
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
		bingus.sprite.flip_x = (move.x > bingus.pos.x);
	} else {
		bingus.walk = 0.0;
	};
};

fn update_bungus(context: *Context, bingus: *Bungus) void = {
	make_decisions(context, bingus);
	do_stuff(context, bingus);
	update_bungus_sprite(context, bingus);
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

fn update_bungus_sprite(context: *Context, bingus: *Bungus) void = {
	// thingle
	let x = bingus.pos.x : int;// bingus.pos.x : int + 640; let ox = x;
	let y = bingus.pos.y : int;// -bingus.pos.y : int + 360; let oy = y;
		
	y += (math::cosf64(get_time() * 18.0) : f32 * bingus.walk): int;

	let wob = math::sinf64(get_time() * 3.0) : f32 * bingus.wiggle;
	let tint = if (bingus.task is Judge) COLOR_JUDGE
		else if (bingus.task is Run) COLOR_RUN
		else COLOR_WHITE;
	let pos = vector2(x : f32, y : f32);

	bingus.sprite.pos = pos;
	bingus.sprite.rot = wob;
	bingus.sprite.tint = tint;
	bingus.sprite.depth = pos.y;
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
	sprite: *Sprite,
	claimed: bool,
};

type Falling = struct {
	sprite: *Sprite,
	targ: Vector2,
	roff: f32,
};
//fn draw_food(food: *Food) void = {
//	let src = Rectangle {
//		x = 0.0, y = 0.0,
//		width  = TEXT_BURGER.width : f32,
//		height = TEXT_BURGER.height : f32,
//	};
//	let centr = Vector2 {
//		x = src.width * 0.5,
//		y = src.height * 0.5,
//	};
//	let dest = src;
//	dest.x = food.pos.x;
//	dest.y = food.pos.y;
//
//	draw_texture_pro(TEXT_BURGER,
//		src,
//		dest,
//		centr,
//		food.rot,
//		COLOR_WHITE,
//	);
//};

fn sprinkle_food(falling: *[]Falling) void = {
	let x = (random::u32n(&RNG, 20) * 25 + 370) : f32;
	let y = (random::u32n(&RNG, 20) * 10 + 360) : f32;

	let sprite = sprite_from_texture(
		TEXT_BURGER,
		vector2(x, -100.0),
	);

	// We register the sprite
	let sprite = add_sprite(&RENDER_QUEUE, sprite);	

	let new = Falling { 
		sprite =  sprite,
		targ = vector2(x, y),
		roff = (random::u32n(&RNG, 3) : f32 - 1.5) * 10.0,
	};
	append(falling, new);
};

// DESIGNATED SPRITE STUFF (:O

type Sprite = struct {
	texture: Texture,
	pos: Vector2,
	tint: Color,
	rot: Degrees,
	depth: f32,
	flip_x: bool,
	flip_y: bool,
};

fn render_sprite(sprite: *Sprite) void = {
	let cx = sprite.texture.width  >> 1;
	let cy = sprite.texture.height >> 1;

	let center = vector2(cx: f32, cy: f32);

	let src_x = if (sprite.flip_x)
		{ yield (-sprite.texture.width, sprite.texture.width); }
	else 	{ yield ( sprite.texture.width,                    0); };
	let src_y = if (sprite.flip_y)
		{ yield (-sprite.texture.height, sprite.texture.height); }
	else 	{ yield ( sprite.texture.height,                     0); };

	let src = Rectangle {
		x = src_x.1 : f32, y = src_y.1 : f32,
		width = src_x.0 : f32, height = src_y.0 : f32,
	};

	let out = Rectangle {
		x = sprite.pos.x, y = sprite.pos.y,
		width = sprite.texture.width : f32,
		height = sprite.texture.height : f32,
	};

	draw_texture_pro(sprite.texture,
		src, out,
		center,
		sprite.rot, sprite.tint
	);
};

fn sort_render_queue(queue: *[]*Sprite) void = {
	for (let ci : size = 0; ci < len(queue); ci += 1)
	for (let i : size = 0; i + 1 < len(queue); i += 1) {
		if (queue[i].depth <= queue[i + 1].depth)
			continue;
		let temp = queue[i];
		queue[i] = queue[i + 1];
		queue[i + 1] = temp;
	};
};

fn remove_sprite(queue: *[]*Sprite, targ: *Sprite) void = {
	if (len(queue) == 0) return;
	for (let i : size = 0; i < len(queue); i += 1) {
		if (queue[i] != targ) continue;
		queue[i] = queue[len(queue) - 1];
		delete(queue[len(queue) - 1]);
		return;
	};
};

fn add_sprite(queue: *[]*Sprite, targ: Sprite) *Sprite = {
	let box : *Sprite = alloc(targ);
	append(queue, box);
	return box;
};

fn sprite_from_texture(texture: Texture, pos: Vector2) Sprite = {
	return Sprite {
		texture = texture,
		pos = pos,
		tint = COLOR_WHITE,
		rot = 0.0,
		flip_x = false,
		flip_y = false,
		depth = pos.y,
	};
};

fn load_sprite(path: *c::char) Sprite = {
	return sprite_from_texture(
		load_texture(path),
		vector2_zero(),
	);
};

// TERRARIUM FLOOR POINT FINDING
//  	ni'n ruŋganda adzerqer axa ni adcrefi eř gandasgriptifi en cywat.

fn get_random_pos() Vector2 = {
	// plan:
	// 	- Get a random position
	//	- map it to the terrarium floor
	
	// screen : 1280 x 720
	// floor  : 1000 x 300 [+ 140 x 390]
	let rx = random::u32n(&RNG, 1000) + 140;
	let ry = random::u32n(&RNG,  300) + 390;
	return vector2(rx : f32, ry : f32);
};

fn clamp_position(pos: Vector2) Vector2 = {
	return vector2_clamp(pos,
		vector2( 140.0, 390.0),
		vector2(1140.0, 690.0),
	);
};
