defmodule Quartz.Color.FunctionBuilder do
  alias Quartz.Formatter

  cmyk_color_data = """
  white (Safe 16 SVG Hex3)	cmyk(0%, 0%, 0%, 0%)	 	gray99	cmyk(0%, 0%, 0%, 1%)	 	gray98	cmyk(0%, 0%, 0%, 2%)
  gray97	cmyk(0%, 0%, 0%, 3%)	 	whitesmoke (SVG)	cmyk(0%, 0%, 0%, 4%)	 	gray95	cmyk(0%, 0%, 0%, 5%)
  gray94	cmyk(0%, 0%, 0%, 6%)	 	gray93	cmyk(0%, 0%, 0%, 7%)	 	gray92	cmyk(0%, 0%, 0%, 8%)
  gray91	cmyk(0%, 0%, 0%, 9%)	 	gray90	cmyk(0%, 0%, 0%, 10%)	 	gray89	cmyk(0%, 0%, 0%, 11%)
  gray88	cmyk(0%, 0%, 0%, 12%)	 	gray87	cmyk(0%, 0%, 0%, 13%)	 	gray86	cmyk(0%, 0%, 0%, 14%)
  gainsboro (SVG)	cmyk(0%, 0%, 0%, 14%)	 	gray85	cmyk(0%, 0%, 0%, 15%)	 	gray84	cmyk(0%, 0%, 0%, 16%)
  lightgrey (SVG)	cmyk(0%, 0%, 0%, 17%)	 	lightgray (SVG)	cmyk(0%, 0%, 0%, 17%)	 	gray83	cmyk(0%, 0%, 0%, 17%)
  gray82	cmyk(0%, 0%, 0%, 18%)	 	gray81	cmyk(0%, 0%, 0%, 19%)	 	verylight grey	cmyk(0%, 0%, 0%, 20%)
  gray80 (Safe Hex3)	cmyk(0%, 0%, 0%, 20%)	 	gray79	cmyk(0%, 0%, 0%, 21%)	 	gray78	cmyk(0%, 0%, 0%, 22%)
  gray77	cmyk(0%, 0%, 0%, 23%)	 	gray76	cmyk(0%, 0%, 0%, 24%)	 	silver (16 SVG)	cmyk(0%, 0%, 0%, 25%)
  gray	cmyk(0%, 0%, 0%, 25%)	 	gray75	cmyk(0%, 0%, 0%, 25%)	 	gray74	cmyk(0%, 0%, 0%, 26%)
  gray73	cmyk(0%, 0%, 0%, 27%)	 	gray72	cmyk(0%, 0%, 0%, 28%)	 	gray71	cmyk(0%, 0%, 0%, 29%)
  gray70	cmyk(0%, 0%, 0%, 30%)	 	gray69	cmyk(0%, 0%, 0%, 31%)	 	gray68	cmyk(0%, 0%, 0%, 32%)
  gray67	cmyk(0%, 0%, 0%, 33%)	 	sgilight gray (Hex3)	cmyk(0%, 0%, 0%, 33%)	 	darkgrey (SVG)	cmyk(0%, 0%, 0%, 34%)
  gray66	cmyk(0%, 0%, 0%, 34%)	 	darkgray (SVG)	cmyk(0%, 0%, 0%, 34%)	 	gray65	cmyk(0%, 0%, 0%, 35%)
  gray64	cmyk(0%, 0%, 0%, 36%)	 	gray63	cmyk(0%, 0%, 0%, 37%)	 	gray62	cmyk(0%, 0%, 0%, 38%)
  gray61	cmyk(0%, 0%, 0%, 39%)	 	gray60 (Safe Hex3)	cmyk(0%, 0%, 0%, 40%)	 	gray59	cmyk(0%, 0%, 0%, 41%)
  gray58	cmyk(0%, 0%, 0%, 42%)	 	gray57	cmyk(0%, 0%, 0%, 43%)	 	gray56	cmyk(0%, 0%, 0%, 44%)
  gray55	cmyk(0%, 0%, 0%, 45%)	 	gray54	cmyk(0%, 0%, 0%, 46%)	 	gray53	cmyk(0%, 0%, 0%, 47%)
  gray52	cmyk(0%, 0%, 0%, 48%)	 	gray51	cmyk(0%, 0%, 0%, 49%)	 	grey (16 SVG)	cmyk(0%, 0%, 0%, 50%)
  gray50	cmyk(0%, 0%, 0%, 50%)	 	gray (16 SVG)	cmyk(0%, 0%, 0%, 50%)	 	gray49	cmyk(0%, 0%, 0%, 51%)
  gray48	cmyk(0%, 0%, 0%, 52%)	 	gray47	cmyk(0%, 0%, 0%, 53%)	 	gray46	cmyk(0%, 0%, 0%, 54%)
  gray45	cmyk(0%, 0%, 0%, 55%)	 	gray44	cmyk(0%, 0%, 0%, 56%)	 	gray43	cmyk(0%, 0%, 0%, 57%)
  gray42	cmyk(0%, 0%, 0%, 58%)	 	dimgrey (SVG)	cmyk(0%, 0%, 0%, 59%)	 	dimgray (SVG)	cmyk(0%, 0%, 0%, 59%)
  gray40 (Safe Hex3)	cmyk(0%, 0%, 0%, 60%)	 	gray39	cmyk(0%, 0%, 0%, 61%)	 	gray38	cmyk(0%, 0%, 0%, 62%)
  gray37	cmyk(0%, 0%, 0%, 63%)	 	gray36	cmyk(0%, 0%, 0%, 64%)	 	gray35	cmyk(0%, 0%, 0%, 65%)
  gray34	cmyk(0%, 0%, 0%, 66%)	 	gray33 (Hex3)	cmyk(0%, 0%, 0%, 67%)	 	gray32	cmyk(0%, 0%, 0%, 68%)
  gray31	cmyk(0%, 0%, 0%, 69%)	 	gray30	cmyk(0%, 0%, 0%, 70%)	 	gray29	cmyk(0%, 0%, 0%, 71%)
  gray28	cmyk(0%, 0%, 0%, 72%)	 	gray27	cmyk(0%, 0%, 0%, 73%)	 	gray26	cmyk(0%, 0%, 0%, 74%)
  gray25	cmyk(0%, 0%, 0%, 75%)	 	gray24	cmyk(0%, 0%, 0%, 76%)	 	gray23	cmyk(0%, 0%, 0%, 77%)
  gray22	cmyk(0%, 0%, 0%, 78%)	 	gray21	cmyk(0%, 0%, 0%, 79%)	 	gray20 (Safe Hex3)	cmyk(0%, 0%, 0%, 80%)
  gray19	cmyk(0%, 0%, 0%, 81%)	 	gray18	cmyk(0%, 0%, 0%, 82%)	 	gray17	cmyk(0%, 0%, 0%, 83%)
  gray16	cmyk(0%, 0%, 0%, 84%)	 	gray15	cmyk(0%, 0%, 0%, 85%)	 	gray14	cmyk(0%, 0%, 0%, 86%)
  gray13	cmyk(0%, 0%, 0%, 87%)	 	gray12	cmyk(0%, 0%, 0%, 88%)	 	gray11	cmyk(0%, 0%, 0%, 89%)
  gray10	cmyk(0%, 0%, 0%, 90%)	 	gray9	cmyk(0%, 0%, 0%, 91%)	 	gray8	cmyk(0%, 0%, 0%, 92%)
  gray7	cmyk(0%, 0%, 0%, 93%)	 	gray6	cmyk(0%, 0%, 0%, 94%)	 	gray5	cmyk(0%, 0%, 0%, 95%)
  gray4	cmyk(0%, 0%, 0%, 96%)	 	gray3	cmyk(0%, 0%, 0%, 97%)	 	gray2	cmyk(0%, 0%, 0%, 98%)
  gray1	cmyk(0%, 0%, 0%, 99%)	 	black (Safe 16 SVG Hex3)	cmyk(0%, 0%, 0%, 100%)	 	stainless steel	cmyk(0%, 0%, 2%, 12%)
  blackberry	cmyk(0%, 0%, 3%, 77%)	 	ivory (SVG)	cmyk(0%, 0%, 6%, 0%)	 	ivory2	cmyk(0%, 0%, 6%, 7%)
  ivory3	cmyk(0%, 0%, 6%, 20%)	 	ivory4	cmyk(0%, 0%, 6%, 45%)	 	beige (SVG)	cmyk(0%, 0%, 10%, 4%)
  fog	cmyk(0%, 0%, 10%, 20%)	 	lightyellow (SVG)	cmyk(0%, 0%, 12%, 0%)	 	light yellow2	cmyk(0%, 0%, 12%, 7%)
  wheat	cmyk(0%, 0%, 12%, 15%)	 	light yellow3	cmyk(0%, 0%, 12%, 20%)	 	light yellow4	cmyk(0%, 0%, 12%, 45%)
  lightgoldenrodyellow (SVG)	cmyk(0%, 0%, 16%, 2%)	 	warmgrey	cmyk(0%, 0%, 18%, 50%)	 	bone (Safe Hex3)	cmyk(0%, 0%, 20%, 0%)
  medium goldenrod	cmyk(0%, 0%, 26%, 8%)	 	popcornyellow (Hex3)	cmyk(0%, 0%, 33%, 0%)	 	khaki	cmyk(0%, 0%, 40%, 38%)
  darkolivegreen	cmyk(0%, 0%, 41%, 69%)	 	goldenrod	cmyk(0%, 0%, 49%, 14%)	 	papaya	cmyk(0%, 0%, 51%, 0%)
  ganegreen (Hex3)	cmyk(0%, 0%, 57%, 53%)	 	sgiolivedrab	cmyk(0%, 0%, 61%, 44%)	 	brightgold	cmyk(0%, 0%, 88%, 15%)
  yellow (Safe 16 SVG Hex3)	cmyk(0%, 0%, 100%, 0%)	 	yellow2 (Hex3)	cmyk(0%, 0%, 100%, 7%)	 	ralphyellow (Safe Hex3)	cmyk(0%, 0%, 100%, 20%)
  yellow3	cmyk(0%, 0%, 100%, 20%)	 	yellow4	cmyk(0%, 0%, 100%, 45%)	 	olive (16 SVG)	cmyk(0%, 0%, 100%, 50%)
  snow4	cmyk(0%, 1%, 1%, 45%)	 	coconut	cmyk(0%, 1%, 19%, 0%)	 	lemonchiffon4	cmyk(0%, 1%, 19%, 45%)
  yellow candy	cmyk(0%, 1%, 41%, 7%)	 	green grape	cmyk(0%, 1%, 90%, 19%)	 	snow (SVG)	cmyk(0%, 2%, 2%, 0%)
  snow2	cmyk(0%, 2%, 2%, 7%)	 	snow3	cmyk(0%, 2%, 2%, 20%)	 	floralwhite (SVG)	cmyk(0%, 2%, 6%, 0%)
  ash	cmyk(0%, 2%, 9%, 22%)	 	cornsilk3	cmyk(0%, 2%, 14%, 20%)	 	sgibrightgray	cmyk(0%, 2%, 14%, 23%)
  cornsilk4	cmyk(0%, 2%, 14%, 45%)	 	lemonchiffon (SVG)	cmyk(0%, 2%, 20%, 0%)	 	lemonchiffon2	cmyk(0%, 2%, 20%, 7%)
  cream city brick	cmyk(0%, 2%, 20%, 11%)	 	lemonchiffon3	cmyk(0%, 2%, 20%, 20%)	 	pickle	cmyk(0%, 2%, 72%, 52%)
  oldlace (SVG)	cmyk(0%, 3%, 9%, 1%)	 	cornsilk (SVG)	cmyk(0%, 3%, 14%, 0%)	 	cornsilk2	cmyk(0%, 3%, 14%, 7%)
  palegoldenrod (SVG)	cmyk(0%, 3%, 29%, 7%)	 	tank	cmyk(0%, 3%, 35%, 62%)	 	darkkhaki (SVG)	cmyk(0%, 3%, 43%, 26%)
  khaki2	cmyk(0%, 3%, 44%, 7%)	 	khaki3	cmyk(0%, 3%, 44%, 20%)	 	seashell4	cmyk(0%, 4%, 6%, 45%)
  seashell (SVG)	cmyk(0%, 4%, 7%, 0%)	 	seashell2	cmyk(0%, 4%, 7%, 7%)	 	seashell3	cmyk(0%, 4%, 7%, 20%)
  titanium	cmyk(0%, 4%, 7%, 29%)	 	linen (SVG)	cmyk(0%, 4%, 8%, 2%)	 	khaki (SVG)	cmyk(0%, 4%, 42%, 6%)
  khaki1	cmyk(0%, 4%, 44%, 0%)	 	khaki4	cmyk(0%, 4%, 44%, 45%)	 	yellow perch	cmyk(0%, 4%, 49%, 12%)
  buttermilk	cmyk(0%, 5%, 29%, 0%)	 	grapefruit	cmyk(0%, 5%, 42%, 5%)	 	lavenderblush (SVG)	cmyk(0%, 6%, 4%, 0%)
  lavenderblush2	cmyk(0%, 6%, 4%, 7%)	 	lavenderblush3	cmyk(0%, 6%, 4%, 20%)	 	lavenderblush4	cmyk(0%, 6%, 4%, 45%)
  manatee gray	cmyk(0%, 6%, 7%, 31%)	 	antiquewhite1	cmyk(0%, 6%, 14%, 0%)	 	peach	cmyk(0%, 6%, 14%, 0%)
  antiquewhite (SVG)	cmyk(0%, 6%, 14%, 2%)	 	antiquewhite2	cmyk(0%, 6%, 14%, 7%)	 	antiquewhite3	cmyk(0%, 6%, 14%, 20%)
  antiquewhite4	cmyk(0%, 6%, 14%, 45%)	 	papayawhip (SVG)	cmyk(0%, 6%, 16%, 0%)	 	corn	cmyk(0%, 6%, 63%, 2%)
  anjou pear	cmyk(0%, 6%, 96%, 27%)	 	light goldenrod1	cmyk(0%, 7%, 45%, 0%)	 	light goldenrod	cmyk(0%, 7%, 45%, 7%)
  light goldenrod3	cmyk(0%, 7%, 45%, 20%)	 	light goldenrod4	cmyk(0%, 7%, 45%, 45%)	 	blanchedalmond (SVG)	cmyk(0%, 8%, 20%, 0%)
  light goldenrod2	cmyk(0%, 8%, 45%, 7%)	 	brass	cmyk(0%, 8%, 64%, 29%)	 	lemon	cmyk(0%, 8%, 74%, 16%)
  desert sand	cmyk(0%, 9%, 16%, 0%)	 	eggshell	cmyk(0%, 9%, 20%, 1%)	 	beige dark	cmyk(0%, 9%, 21%, 36%)
  wheat1	cmyk(0%, 9%, 27%, 0%)	 	wheat (SVG)	cmyk(0%, 9%, 27%, 4%)	 	wheat2	cmyk(0%, 9%, 27%, 7%)
  wheat3	cmyk(0%, 9%, 27%, 20%)	 	wheat4	cmyk(0%, 9%, 27%, 45%)	 	banana	cmyk(0%, 9%, 62%, 11%)
  pink glass	cmyk(0%, 10%, 2%, 17%)	 	mistyrose4	cmyk(0%, 10%, 12%, 45%)	 	bisque4	cmyk(0%, 10%, 23%, 45%)
  beach sand	cmyk(0%, 10%, 26%, 7%)	 	honey	cmyk(0%, 10%, 32%, 0%)	 	yolk	cmyk(0%, 10%, 100%, 0%)
  blue corn chips	cmyk(0%, 11%, 2%, 65%)	 	mistyrose (SVG)	cmyk(0%, 11%, 12%, 0%)	 	mistyrose2	cmyk(0%, 11%, 12%, 7%)
  mistyrose3	cmyk(0%, 11%, 12%, 20%)	 	bisque (SVG)	cmyk(0%, 11%, 23%, 0%)	 	bisque2	cmyk(0%, 11%, 23%, 7%)
  bisque3	cmyk(0%, 11%, 23%, 20%)	 	moccasin (SVG)	cmyk(0%, 11%, 29%, 0%)	 	cadmiumlemon	cmyk(0%, 11%, 99%, 0%)
  thistle1	cmyk(0%, 12%, 0%, 0%)	 	thistle2	cmyk(0%, 12%, 0%, 7%)	 	thistle (SVG)	cmyk(0%, 12%, 0%, 15%)
  thistle3	cmyk(0%, 12%, 0%, 20%)	 	thistle4	cmyk(0%, 12%, 0%, 45%)	 	ivoryblack	cmyk(0%, 12%, 20%, 84%)
  pistachio shell	cmyk(0%, 12%, 27%, 8%)	 	mocha latte	cmyk(0%, 13%, 26%, 21%)	 	navajowhite (SVG)	cmyk(0%, 13%, 32%, 0%)
  navajowhite2	cmyk(0%, 13%, 32%, 7%)	 	navajowhite3	cmyk(0%, 13%, 32%, 20%)	 	navajowhite4	cmyk(0%, 13%, 32%, 45%)
  canvas	cmyk(0%, 13%, 48%, 38%)	 	oldgold	cmyk(0%, 13%, 71%, 19%)	 	pineapple	cmyk(0%, 13%, 77%, 1%)
  gummi yellow	cmyk(0%, 13%, 95%, 2%)	 	peachpuff4	cmyk(0%, 14%, 27%, 45%)	 	espresso	cmyk(0%, 14%, 29%, 9%)
  tan (SVG)	cmyk(0%, 14%, 33%, 18%)	 	bronze	cmyk(0%, 14%, 41%, 45%)	 	orange candy	cmyk(0%, 14%, 43%, 16%)
  dark wheat	cmyk(0%, 14%, 44%, 9%)	 	golden delicious apple	cmyk(0%, 14%, 59%, 7%)	 	corfu pink	cmyk(0%, 15%, 0%, 7%)
  peachpuff (SVG)	cmyk(0%, 15%, 27%, 0%)	 	peachpuff2	cmyk(0%, 15%, 27%, 7%)	 	peachpuff3	cmyk(0%, 15%, 27%, 20%)
  newtan	cmyk(0%, 15%, 33%, 8%)	 	bread	cmyk(0%, 15%, 38%, 1%)	 	sandstone	cmyk(0%, 16%, 21%, 35%)
  gold (SVG)	cmyk(0%, 16%, 100%, 0%)	 	gold2	cmyk(0%, 16%, 100%, 7%)	 	gold3	cmyk(0%, 16%, 100%, 20%)
  gold4	cmyk(0%, 16%, 100%, 45%)	 	pink shell	cmyk(0%, 17%, 11%, 4%)	 	piglet snout	cmyk(0%, 17%, 19%, 7%)
  light wood	cmyk(0%, 17%, 29%, 9%)	 	burlywood1	cmyk(0%, 17%, 39%, 0%)	 	burlywood2	cmyk(0%, 17%, 39%, 7%)
  burlywood (SVG)	cmyk(0%, 17%, 39%, 13%)	 	burlywood3	cmyk(0%, 17%, 39%, 20%)	 	burlywood4	cmyk(0%, 17%, 39%, 45%)
  bartlett pear	cmyk(0%, 17%, 78%, 20%)	 	sign yellow	cmyk(0%, 17%, 91%, 1%)	 	bermuda sand	cmyk(0%, 18%, 17%, 4%)
  light copper	cmyk(0%, 18%, 38%, 7%)	 	beer	cmyk(0%, 18%, 74%, 10%)	 	conch	cmyk(0%, 19%, 18%, 18%)
  flatpink (Safe Hex3)	cmyk(0%, 20%, 20%, 0%)	 	sand (Safe Hex3)	cmyk(0%, 20%, 40%, 0%)	 	mustard (Hex3)	cmyk(0%, 20%, 93%, 0%)
  cashew	cmyk(0%, 22%, 48%, 13%)	 	semisweet chocolate2	cmyk(0%, 22%, 83%, 10%)	 	strawberry smoothie	cmyk(0%, 23%, 16%, 8%)
  medium wood	cmyk(0%, 23%, 40%, 35%)	 	cheddar	cmyk(0%, 23%, 59%, 0%)	 	rosybrown1	cmyk(0%, 24%, 24%, 0%)
  rosybrown2	cmyk(0%, 24%, 24%, 7%)	 	rosybrown3	cmyk(0%, 24%, 24%, 20%)	 	rosybrown (SVG)	cmyk(0%, 24%, 24%, 26%)
  rosybrown4	cmyk(0%, 24%, 24%, 45%)	 	goldenrod1	cmyk(0%, 24%, 85%, 0%)	 	goldenrod (SVG)	cmyk(0%, 24%, 85%, 15%)
  goldenrod2	cmyk(0%, 24%, 86%, 7%)	 	goldenrod3	cmyk(0%, 24%, 86%, 20%)	 	goldenrod4	cmyk(0%, 24%, 86%, 45%)
  lavender (Safe Hex3)	cmyk(0%, 25%, 0%, 20%)	 	pink (SVG)	cmyk(0%, 25%, 20%, 0%)	 	cappuccino	cmyk(0%, 25%, 60%, 30%)
  bronzeii	cmyk(0%, 25%, 63%, 35%)	 	sienna	cmyk(0%, 25%, 75%, 44%)	 	plum2	cmyk(0%, 26%, 0%, 8%)
  pink candy	cmyk(0%, 26%, 7%, 14%)	 	dustyrose	cmyk(0%, 26%, 26%, 48%)	 	melon	cmyk(0%, 26%, 54%, 11%)
  cafe americano	cmyk(0%, 26%, 54%, 79%)	 	organic tea	cmyk(0%, 26%, 79%, 33%)	 	plum1 (Hex3)	cmyk(0%, 27%, 0%, 0%)
  plum2	cmyk(0%, 27%, 0%, 7%)	 	plum3	cmyk(0%, 27%, 0%, 20%)	 	plum4	cmyk(0%, 27%, 0%, 45%)
  darkgoldenrod1	cmyk(0%, 27%, 94%, 0%)	 	darkgoldenrod2	cmyk(0%, 27%, 94%, 7%)	 	darkgoldenrod3	cmyk(0%, 27%, 94%, 20%)
  darkgoldenrod (SVG)	cmyk(0%, 27%, 94%, 28%)	 	darkgoldenrod4	cmyk(0%, 27%, 94%, 45%)	 	plum (SVG)	cmyk(0%, 28%, 0%, 13%)
  cotton candy	cmyk(0%, 28%, 12%, 3%)	 	ham	cmyk(0%, 28%, 24%, 14%)	 	almond	cmyk(0%, 28%, 63%, 23%)
  packer gold	cmyk(0%, 28%, 92%, 1%)	 	pink4	cmyk(0%, 29%, 22%, 45%)	 	pink1	cmyk(0%, 29%, 23%, 0%)
  pink2	cmyk(0%, 29%, 23%, 7%)	 	pink3	cmyk(0%, 29%, 23%, 20%)	 	lightpink (SVG)	cmyk(0%, 29%, 24%, 0%)
  darkwood	cmyk(0%, 29%, 50%, 48%)	 	feldspar	cmyk(0%, 30%, 44%, 18%)	 	verydarkbrown	cmyk(0%, 30%, 45%, 64%)
  darktan	cmyk(0%, 30%, 48%, 41%)	 	latte	cmyk(0%, 30%, 64%, 38%)	 	pyridiumorange	cmyk(0%, 30%, 98%, 6%)
  purple ink	cmyk(0%, 31%, 3%, 39%)	 	cadmium yellowlight	cmyk(0%, 31%, 94%, 0%)	 	grape	cmyk(0%, 32%, 14%, 67%)
  amethyst	cmyk(0%, 32%, 16%, 38%)	 	pink cloud	cmyk(0%, 32%, 26%, 4%)	 	peachpuff	cmyk(0%, 32%, 27%, 0%)
  light pink1	cmyk(0%, 32%, 27%, 0%)	 	light pink2	cmyk(0%, 32%, 27%, 7%)	 	tongue	cmyk(0%, 32%, 27%, 9%)
  light pink3	cmyk(0%, 32%, 27%, 20%)	 	light pink4	cmyk(0%, 32%, 27%, 45%)	 	cafe au lait	cmyk(0%, 32%, 66%, 29%)
  dog tongue	cmyk(0%, 33%, 13%, 4%)	 	black beauty plum	cmyk(0%, 33%, 29%, 74%)	 	tan	cmyk(0%, 33%, 49%, 14%)
  sandybrown (SVG)	cmyk(0%, 33%, 61%, 4%)	 	gold7 (Hex3)	cmyk(0%, 33%, 100%, 0%)	 	aureolineyellow	cmyk(0%, 34%, 86%, 0%)
  naplesyellowdeep	cmyk(0%, 34%, 93%, 0%)	 	tan1	cmyk(0%, 35%, 69%, 0%)	 	tan2	cmyk(0%, 35%, 69%, 7%)
  peru (SVG)	cmyk(0%, 35%, 69%, 20%)	 	tan4	cmyk(0%, 35%, 69%, 45%)	 	brick	cmyk(0%, 35%, 80%, 39%)
  orange (SVG)	cmyk(0%, 35%, 100%, 0%)	 	orange2	cmyk(0%, 35%, 100%, 7%)	 	orange3	cmyk(0%, 35%, 100%, 20%)
  orange4	cmyk(0%, 35%, 100%, 45%)	 	purple fish	cmyk(0%, 36%, 7%, 30%)	 	darksalmon (SVG)	cmyk(0%, 36%, 48%, 9%)
  apricot	cmyk(0%, 36%, 57%, 2%)	 	rawumber	cmyk(0%, 36%, 84%, 55%)	 	lightsalmon (SVG)	cmyk(0%, 37%, 52%, 0%)
  light salmon2	cmyk(0%, 37%, 52%, 7%)	 	light salmon3	cmyk(0%, 37%, 52%, 20%)	 	light salmon4	cmyk(0%, 37%, 53%, 45%)
  coconut shell	cmyk(0%, 37%, 65%, 26%)	 	pecan	cmyk(0%, 37%, 80%, 12%)	 	20 pound	cmyk(0%, 38%, 21%, 36%)
  semisweet chocolate1	cmyk(0%, 38%, 64%, 58%)	 	cantaloupe pulp	cmyk(0%, 38%, 68%, 2%)	 	copper	cmyk(0%, 38%, 72%, 28%)
  gold5	cmyk(0%, 38%, 75%, 20%)	 	gold6	cmyk(0%, 38%, 76%, 20%)	 	cool copper	cmyk(0%, 38%, 88%, 15%)
  kumquat	cmyk(0%, 38%, 96%, 14%)	 	carrot	cmyk(0%, 39%, 86%, 7%)	 	blueviolet	cmyk(0%, 40%, 0%, 38%)
  carnation	cmyk(0%, 40%, 20%, 13%)	 	smyrna purple	cmyk(0%, 40%, 25%, 36%)	 	peach (Hex3)	cmyk(0%, 40%, 67%, 0%)
  goldochre	cmyk(0%, 40%, 81%, 22%)	 	cadmiumyellow	cmyk(0%, 40%, 93%, 0%)	 	cinnamon (Hex3)	cmyk(0%, 40%, 100%, 33%)
  violet	cmyk(0%, 41%, 0%, 69%)	 	salmon5	cmyk(0%, 41%, 41%, 56%)	 	ochre (Hex3)	cmyk(0%, 42%, 83%, 20%)
  bubble gum	cmyk(0%, 43%, 27%, 0%)	 	sgisalmon	cmyk(0%, 43%, 43%, 22%)	 	tan (Hex3)	cmyk(0%, 43%, 79%, 7%)
  yellowochre	cmyk(0%, 43%, 90%, 11%)	 	sea urchin	cmyk(0%, 44%, 10%, 59%)	 	violet (SVG)	cmyk(0%, 45%, 0%, 7%)
  salmon1	cmyk(0%, 45%, 59%, 0%)	 	salmon2	cmyk(0%, 45%, 59%, 7%)	 	salmon3	cmyk(0%, 45%, 59%, 20%)
  salmon4	cmyk(0%, 45%, 59%, 45%)	 	bakerschocolate	cmyk(0%, 45%, 75%, 64%)	 	crema	cmyk(0%, 45%, 97%, 22%)
  darkorange (SVG)	cmyk(0%, 45%, 100%, 0%)	 	lightcoral (SVG)	cmyk(0%, 47%, 47%, 6%)	 	deepochre	cmyk(0%, 47%, 77%, 55%)
  mandarianorange	cmyk(0%, 47%, 78%, 11%)	 	sign brown	cmyk(0%, 47%, 82%, 62%)	 	darkorange5	cmyk(0%, 47%, 100%, 0%)
  sign orange	cmyk(0%, 47%, 100%, 13%)	 	fuji apple	cmyk(0%, 48%, 54%, 16%)	 	orchid	cmyk(0%, 49%, 0%, 14%)
  orchid4	cmyk(0%, 49%, 1%, 45%)	 	orchid1	cmyk(0%, 49%, 2%, 0%)	 	orchid2	cmyk(0%, 49%, 2%, 7%)
  orchid (SVG)	cmyk(0%, 49%, 2%, 15%)	 	orchid3	cmyk(0%, 49%, 2%, 20%)	 	palevioletred1	cmyk(0%, 49%, 33%, 0%)
  palevioletred2	cmyk(0%, 49%, 33%, 7%)	 	palevioletred (SVG)	cmyk(0%, 49%, 33%, 14%)	 	palevioletred3	cmyk(0%, 49%, 33%, 20%)
  palevioletred4	cmyk(0%, 49%, 33%, 45%)	 	salmon (SVG)	cmyk(0%, 49%, 54%, 2%)	 	sienna1	cmyk(0%, 49%, 72%, 0%)
  sienna2	cmyk(0%, 49%, 72%, 7%)	 	sienna3	cmyk(0%, 49%, 72%, 20%)	 	sienna (SVG)	cmyk(0%, 49%, 72%, 37%)
  sienna4	cmyk(0%, 49%, 73%, 45%)	 	cinnamon	cmyk(0%, 49%, 100%, 52%)	 	coral (SVG)	cmyk(0%, 50%, 69%, 0%)
  chocolate1	cmyk(0%, 50%, 86%, 0%)	 	chocolate2	cmyk(0%, 50%, 86%, 7%)	 	chocolate (SVG)	cmyk(0%, 50%, 86%, 18%)
  chocolate3	cmyk(0%, 50%, 86%, 20%)	 	saddlebrown (SVG)	cmyk(0%, 50%, 86%, 45%)	 	orange	cmyk(0%, 50%, 100%, 0%)
  darkorange1	cmyk(0%, 50%, 100%, 0%)	 	darkorange2	cmyk(0%, 50%, 100%, 7%)	 	darkorange3	cmyk(0%, 50%, 100%, 20%)
  darkorange4	cmyk(0%, 50%, 100%, 45%)	 	pummelo pulp	cmyk(0%, 51%, 63%, 4%)	 	orange5	cmyk(0%, 51%, 75%, 0%)
  brownochre	cmyk(0%, 51%, 77%, 47%)	 	marsyellow	cmyk(0%, 51%, 89%, 11%)	 	rawsienna	cmyk(0%, 51%, 90%, 22%)
  coffee	cmyk(0%, 51%, 98%, 33%)	 	hotpink3	cmyk(0%, 53%, 30%, 20%)	 	bacon	cmyk(0%, 53%, 56%, 22%)
  red roof	cmyk(0%, 53%, 61%, 22%)	 	orange crush	cmyk(0%, 53%, 80%, 3%)	 	oregon salmon (Hex3)	cmyk(0%, 53%, 87%, 0%)
  marsorange	cmyk(0%, 54%, 87%, 41%)	 	hotpink2	cmyk(0%, 55%, 30%, 7%)	 	indianred (SVG)	cmyk(0%, 55%, 55%, 20%)
  coral1	cmyk(0%, 55%, 66%, 0%)	 	coral2	cmyk(0%, 55%, 66%, 7%)	 	coral4	cmyk(0%, 55%, 66%, 45%)
  tangerine	cmyk(0%, 55%, 91%, 0%)	 	thistle	cmyk(0%, 56%, 14%, 29%)	 	coral3	cmyk(0%, 56%, 66%, 20%)
  neonpink	cmyk(0%, 57%, 22%, 0%)	 	hotpink1	cmyk(0%, 57%, 29%, 0%)	 	hotpink4	cmyk(0%, 58%, 29%, 45%)
  indianred1	cmyk(0%, 58%, 58%, 0%)	 	indianred2	cmyk(0%, 58%, 58%, 7%)	 	indianred4	cmyk(0%, 58%, 58%, 45%)
  hotpink (SVG)	cmyk(0%, 59%, 29%, 0%)	 	bunny eye	cmyk(0%, 59%, 44%, 35%)	 	indianred3	cmyk(0%, 59%, 59%, 20%)
  cherry	cmyk(0%, 60%, 57%, 8%)	 	seattle salmon (Safe Hex3)	cmyk(0%, 60%, 60%, 0%)	 	sepia	cmyk(0%, 60%, 81%, 63%)
  vandykebrown	cmyk(0%, 60%, 95%, 63%)	 	orange (Safe Hex3)	cmyk(0%, 60%, 100%, 0%)	 	sgibeet	cmyk(0%, 61%, 0%, 44%)
  tomato (SVG)	cmyk(0%, 61%, 72%, 0%)	 	tomato2	cmyk(0%, 61%, 72%, 7%)	 	tomato3	cmyk(0%, 61%, 72%, 20%)
  tomato4	cmyk(0%, 61%, 73%, 45%)	 	burntsienna	cmyk(0%, 61%, 89%, 46%)	 	apple	cmyk(0%, 62%, 55%, 20%)
  cadmiumorange	cmyk(0%, 62%, 99%, 0%)	 	cola	cmyk(0%, 63%, 70%, 31%)	 	burntumber	cmyk(0%, 63%, 74%, 46%)
  jonathan apple	cmyk(0%, 63%, 76%, 30%)	 	hematite	cmyk(0%, 64%, 64%, 11%)	 	kidney bean	cmyk(0%, 65%, 92%, 31%)
  chili	cmyk(0%, 66%, 69%, 17%)	 	fleshochre	cmyk(0%, 66%, 87%, 0%)	 	brown	cmyk(0%, 67%, 67%, 50%)
  safety cone	cmyk(0%, 67%, 80%, 0%)	 	chocolate (Safe Hex3)	cmyk(0%, 67%, 100%, 40%)	 	chili powder	cmyk(0%, 68%, 88%, 22%)
  plum pudding	cmyk(0%, 69%, 40%, 47%)	 	cranberry jello	cmyk(0%, 69%, 54%, 4%)	 	pomegranate	cmyk(0%, 69%, 66%, 4%)
  maroon5	cmyk(0%, 70%, 99%, 59%)	 	pink jeep	cmyk(0%, 71%, 43%, 12%)	 	watermelon pulp	cmyk(0%, 71%, 74%, 5%)
  englishred	cmyk(0%, 71%, 88%, 17%)	 	soylent red	cmyk(0%, 71%, 97%, 12%)	 	raspberry	cmyk(0%, 72%, 36%, 47%)
  cranberry	cmyk(0%, 73%, 41%, 29%)	 	maroonb0	cmyk(0%, 73%, 45%, 31%)	 	orangered (SVG)	cmyk(0%, 73%, 100%, 0%)
  orangered2	cmyk(0%, 73%, 100%, 7%)	 	orangered3	cmyk(0%, 73%, 100%, 20%)	 	brown1	cmyk(0%, 73%, 100%, 45%)
  violetred	cmyk(0%, 75%, 25%, 20%)	 	maroon6	cmyk(0%, 75%, 25%, 44%)	 	orangered4	cmyk(0%, 75%, 75%, 0%)
  brown2	cmyk(0%, 75%, 75%, 7%)	 	brown3	cmyk(0%, 75%, 75%, 20%)	 	orange	cmyk(0%, 75%, 75%, 20%)
  brown (SVG)	cmyk(0%, 75%, 75%, 35%)	 	brown	cmyk(0%, 75%, 75%, 35%)	 	firebrick5	cmyk(0%, 75%, 75%, 44%)
  brown4	cmyk(0%, 75%, 75%, 45%)	 	violetred1	cmyk(0%, 76%, 41%, 0%)	 	violetred2	cmyk(0%, 76%, 41%, 7%)
  violetred3	cmyk(0%, 76%, 41%, 20%)	 	violetred4	cmyk(0%, 76%, 41%, 45%)	 	passion fruit	cmyk(0%, 76%, 67%, 67%)
  rosemadder	cmyk(0%, 76%, 75%, 11%)	 	greenishumber	cmyk(0%, 76%, 95%, 0%)	 	darkpurple	cmyk(0%, 77%, 11%, 47%)
  barney	cmyk(0%, 77%, 34%, 17%)	 	bing cherry	cmyk(0%, 77%, 79%, 37%)	 	braeburn apple	cmyk(0%, 78%, 68%, 27%)
  maroon4	cmyk(0%, 80%, 29%, 45%)	 	maroon1	cmyk(0%, 80%, 30%, 0%)	 	maroon2	cmyk(0%, 80%, 30%, 7%)
  maroon3	cmyk(0%, 80%, 30%, 20%)	 	madderlakedeep	cmyk(0%, 80%, 79%, 11%)	 	novascotia salmon (Safe Hex3)	cmyk(0%, 80%, 80%, 0%)
  strawberry	cmyk(0%, 80%, 81%, 25%)	 	nectarine (Safe Hex3)	cmyk(0%, 80%, 100%, 0%)	 	deeppurple	cmyk(0%, 81%, 40%, 67%)
  ruby red	cmyk(0%, 81%, 73%, 22%)	 	burntsienna	cmyk(0%, 81%, 80%, 67%)	 	firebrick1	cmyk(0%, 81%, 81%, 0%)
  brownmadder	cmyk(0%, 81%, 81%, 14%)	 	firebrick3	cmyk(0%, 81%, 81%, 20%)	 	firebrick (SVG)	cmyk(0%, 81%, 81%, 30%)
  firebrick4	cmyk(0%, 81%, 81%, 45%)	 	harold's crayon	cmyk(0%, 82%, 27%, 29%)	 	firebrick2	cmyk(0%, 82%, 82%, 7%)
  permanent redviolet	cmyk(0%, 83%, 68%, 14%)	 	sign red	cmyk(0%, 83%, 74%, 31%)	 	alizarin crimson	cmyk(0%, 83%, 76%, 11%)
  bordeaux	cmyk(0%, 84%, 71%, 40%)	 	scarlet	cmyk(0%, 84%, 84%, 45%)	 	violetred	cmyk(0%, 85%, 31%, 18%)
  orangered	cmyk(0%, 86%, 100%, 0%)	 	indianred	cmyk(0%, 87%, 82%, 31%)	 	raspberry red	cmyk(0%, 88%, 81%, 2%)
  venetianred	cmyk(0%, 88%, 85%, 17%)	 	red delicious apple	cmyk(0%, 88%, 94%, 38%)	 	spicypink	cmyk(0%, 89%, 32%, 0%)
  mediumvioletred (SVG)	cmyk(0%, 89%, 33%, 22%)	 	red coat	cmyk(0%, 90%, 80%, 28%)	 	cadmiumreddeep	cmyk(0%, 90%, 94%, 11%)
  crimson (SVG)	cmyk(0%, 91%, 73%, 14%)	 	deeppink (SVG)	cmyk(0%, 92%, 42%, 0%)	 	deeppink2	cmyk(0%, 92%, 42%, 7%)
  deeppink3	cmyk(0%, 92%, 42%, 20%)	 	geraniumlake	cmyk(0%, 92%, 79%, 11%)	 	gummi red	cmyk(0%, 92%, 100%, 1%)
  bloodorange (Hex3)	cmyk(0%, 92%, 100%, 20%)	 	deeppink4	cmyk(0%, 93%, 42%, 45%)	 	burgundy	cmyk(0%, 97%, 95%, 38%)
  cadmiumredlight	cmyk(0%, 99%, 95%, 0%)	 	magenta (Safe 16=fuchsia SVG Hex3)	cmyk(0%, 100%, 0%, 0%)	 	fuchsia (Safe 16 SVG Hex3)	cmyk(0%, 100%, 0%, 0%)
  magenta2 (Hex3)	cmyk(0%, 100%, 0%, 7%)	 	magenta3	cmyk(0%, 100%, 0%, 20%)	 	truepurple (Safe Hex3)	cmyk(0%, 100%, 0%, 40%)
  darkmagenta (SVG)	cmyk(0%, 100%, 0%, 45%)	 	purple (16 SVG)	cmyk(0%, 100%, 0%, 50%)	 	rose (Safe Hex3)	cmyk(0%, 100%, 20%, 0%)
  fuchsia2 (Hex3)	cmyk(0%, 100%, 33%, 0%)	 	orangered	cmyk(0%, 100%, 50%, 0%)	 	broadwaypink (Safe Hex3)	cmyk(0%, 100%, 60%, 0%)
  bright red (Safe Hex3)	cmyk(0%, 100%, 80%, 0%)	 	red (Safe 16 SVG Hex3)	cmyk(0%, 100%, 100%, 0%)	 	red2 (Hex3)	cmyk(0%, 100%, 100%, 7%)
  red3	cmyk(0%, 100%, 100%, 20%)	 	darkred (SVG)	cmyk(0%, 100%, 100%, 45%)	 	maroon (16 SVG)	cmyk(0%, 100%, 100%, 50%)
  bloodred (Safe Hex3)	cmyk(0%, 100%, 100%, 60%)	 	darkcherryred (Safe Hex3)	cmyk(0%, 100%, 100%, 80%)	 	titaniumwhite	cmyk(1%, 0%, 6%, 0%)
  battleship	cmyk(1%, 0%, 7%, 18%)	 	soylent yellow	cmyk(1%, 0%, 52%, 3%)	 	zincwhite	cmyk(1%, 3%, 0%, 0%)
  lavender field	cmyk(2%, 37%, 0%, 53%)	 	turnip	cmyk(2%, 56%, 0%, 33%)	 	ghostwhite (SVG)	cmyk(3%, 3%, 0%, 0%)
  mintcream (SVG)	cmyk(4%, 0%, 2%, 0%)	 	chrome	cmyk(4%, 0%, 12%, 5%)	 	celery	cmyk(4%, 0%, 39%, 16%)
  eggplant	cmyk(4%, 24%, 0%, 47%)	 	moon	cmyk(5%, 0%, 3%, 10%)	 	camo1	cmyk(5%, 0%, 10%, 14%)
  fire truck green	cmyk(5%, 0%, 98%, 16%)	 	azure (SVG)	cmyk(6%, 0%, 0%, 0%)	 	azure2	cmyk(6%, 0%, 0%, 7%)
  azure3	cmyk(6%, 0%, 0%, 20%)	 	azure4	cmyk(6%, 0%, 0%, 45%)	 	honeydew (SVG)	cmyk(6%, 0%, 6%, 0%)
  honeydew2	cmyk(6%, 0%, 6%, 7%)	 	honeydew3	cmyk(6%, 0%, 6%, 20%)	 	honeydew4	cmyk(6%, 0%, 6%, 45%)
  park ranger	cmyk(6%, 0%, 9%, 70%)	 	flight jacket	cmyk(6%, 0%, 11%, 47%)	 	avocado	cmyk(6%, 0%, 55%, 37%)
  aliceblue (SVG)	cmyk(6%, 3%, 0%, 0%)	 	coldgrey	cmyk(7%, 0%, 2%, 46%)	 	wasabi sauce	cmyk(7%, 0%, 57%, 27%)
  aluminum	cmyk(7%, 5%, 0%, 29%)	 	purple candy	cmyk(7%, 21%, 0%, 20%)	 	violet	cmyk(7%, 39%, 0%, 40%)
  brushed aluminum	cmyk(8%, 0%, 4%, 23%)	 	new $20	cmyk(8%, 0%, 9%, 22%)	 	cantaloupe	cmyk(8%, 0%, 10%, 34%)
  pear	cmyk(8%, 0%, 78%, 11%)	 	silver	cmyk(8%, 7%, 0%, 2%)	 	lavender (SVG)	cmyk(8%, 8%, 0%, 2%)
  cobaltvioletdeep	cmyk(8%, 79%, 0%, 38%)	 	lizard	cmyk(9%, 0%, 18%, 61%)	 	seaweed	cmyk(10%, 0%, 15%, 56%)
  iceberg lettuce	cmyk(10%, 0%, 50%, 11%)	 	garden plum	cmyk(10%, 21%, 0%, 51%)	 	indigo tile	cmyk(10%, 31%, 0%, 50%)
  blue ice	cmyk(11%, 0%, 2%, 4%)	 	seaweed roll	cmyk(11%, 0%, 19%, 49%)	 	cactus	cmyk(11%, 0%, 22%, 56%)
  limepulp	cmyk(11%, 0%, 39%, 7%)	 	key lime pie	cmyk(11%, 0%, 55%, 21%)	 	quartz	cmyk(11%, 11%, 0%, 5%)
  lightcyan (SVG)	cmyk(12%, 0%, 0%, 0%)	 	light cyan2	cmyk(12%, 0%, 0%, 7%)	 	light blue	cmyk(12%, 0%, 0%, 15%)
  light cyan3	cmyk(12%, 0%, 0%, 20%)	 	light cyan4	cmyk(12%, 0%, 0%, 45%)	 	lichen	cmyk(12%, 0%, 19%, 15%)
  heather blue	cmyk(12%, 6%, 0%, 18%)	 	medium orchid1	cmyk(12%, 60%, 0%, 0%)	 	medium orchid2	cmyk(12%, 60%, 0%, 7%)
  mediumorchid (SVG)	cmyk(12%, 60%, 0%, 17%)	 	medium orchid3	cmyk(12%, 60%, 0%, 20%)	 	medium orchid4	cmyk(12%, 60%, 0%, 45%)
  mint ice cream	cmyk(13%, 0%, 16%, 11%)	 	green goo	cmyk(13%, 0%, 21%, 46%)	 	melonrindgreen	cmyk(13%, 0%, 35%, 0%)
  mint blue	cmyk(14%, 0%, 2%, 0%)	 	shamrock shake	cmyk(14%, 0%, 13%, 18%)	 	camo3	cmyk(14%, 0%, 23%, 29%)
  kermit	cmyk(14%, 0%, 90%, 26%)	 	green cheese	cmyk(15%, 0%, 24%, 34%)	 	green quartz	cmyk(15%, 0%, 25%, 36%)
  od green	cmyk(15%, 0%, 27%, 68%)	 	watermelon rind	cmyk(15%, 0%, 56%, 61%)	 	martini olive	cmyk(15%, 0%, 57%, 36%)
  breadfruit	cmyk(15%, 0%, 75%, 39%)	 	army uniform	cmyk(16%, 0%, 2%, 75%)	 	vanilla mint	cmyk(16%, 0%, 11%, 16%)
  camo2	cmyk(16%, 0%, 18%, 21%)	 	broccoli	cmyk(16%, 0%, 30%, 59%)	 	mint candy	cmyk(16%, 0%, 32%, 27%)
  avacado	cmyk(16%, 0%, 55%, 24%)	 	blue nile	cmyk(16%, 14%, 0%, 42%)	 	ultramarine violet	cmyk(16%, 67%, 0%, 57%)
  green card	cmyk(17%, 0%, 5%, 2%)	 	pond scum	cmyk(17%, 0%, 29%, 51%)	 	soylent green	cmyk(17%, 0%, 33%, 34%)
  cat eye	cmyk(17%, 0%, 63%, 10%)	 	dolphin	cmyk(17%, 14%, 0%, 48%)	 	snake	cmyk(18%, 0%, 20%, 58%)
  kiwi	cmyk(18%, 0%, 34%, 40%)	 	jack pine	cmyk(18%, 0%, 77%, 69%)	 	safety vest	cmyk(18%, 0%, 84%, 4%)
  robin's egg	cmyk(18%, 4%, 0%, 7%)	 	LCD back	cmyk(19%, 0%, 13%, 29%)	 	tea leaves	cmyk(19%, 0%, 20%, 54%)
  sweet potato vine	cmyk(19%, 0%, 71%, 21%)	 	chartreuse verte	cmyk(19%, 0%, 76%, 9%)	 	blue dog	cmyk(19%, 9%, 0%, 60%)
  offwhitegreen (Safe Hex3)	cmyk(20%, 0%, 20%, 0%)	 	green hornet	cmyk(20%, 0%, 36%, 48%)	 	pea	cmyk(20%, 0%, 58%, 41%)
  chromeoxidegreen	cmyk(20%, 0%, 84%, 50%)	 	offwhiteblue (Safe Hex3)	cmyk(20%, 20%, 0%, 0%)	 	grape (Safe Hex3)	cmyk(20%, 100%, 0%, 0%)
  green mist	cmyk(21%, 0%, 39%, 7%)	 	darkolivegreen1	cmyk(21%, 0%, 56%, 0%)	 	darkolivegreen2	cmyk(21%, 0%, 56%, 7%)
  darkolivegreen3	cmyk(21%, 0%, 56%, 20%)	 	darkolivegreen4	cmyk(21%, 0%, 56%, 45%)	 	darkolivegreen (SVG)	cmyk(21%, 0%, 56%, 58%)
  light steelblue1	cmyk(21%, 12%, 0%, 0%)	 	light steelblue2	cmyk(21%, 12%, 0%, 7%)	 	lightsteelblue (SVG)	cmyk(21%, 12%, 0%, 13%)
  light steelblue3	cmyk(21%, 12%, 0%, 20%)	 	light steelblue4	cmyk(21%, 12%, 0%, 45%)	 	england pound	cmyk(22%, 0%, 15%, 48%)
  pastel blue	cmyk(22%, 2%, 0%, 4%)	 	slategray1	cmyk(22%, 11%, 0%, 0%)	 	slategray2	cmyk(22%, 11%, 0%, 7%)
  slategray3	cmyk(22%, 11%, 0%, 20%)	 	lightslategrey (SVG Hex3)	cmyk(22%, 11%, 0%, 40%)	 	lightslategray (SVG Hex3)	cmyk(22%, 11%, 0%, 40%)
  slategrey (SVG)	cmyk(22%, 11%, 0%, 44%)	 	slategray (SVG)	cmyk(22%, 11%, 0%, 44%)	 	slategray4	cmyk(22%, 12%, 0%, 45%)
  purple rose	cmyk(22%, 63%, 0%, 53%)	 	green bark	cmyk(23%, 0%, 10%, 55%)	 	fisherman's float	cmyk(23%, 0%, 11%, 51%)
  guacamole	cmyk(23%, 0%, 38%, 16%)	 	jolly green	cmyk(23%, 0%, 88%, 20%)	 	goldgreen (Hex3)	cmyk(23%, 0%, 100%, 13%)
  powderblue (SVG)	cmyk(23%, 3%, 0%, 10%)	 	purple rain	cmyk(23%, 50%, 0%, 46%)	 	darkseagreen1	cmyk(24%, 0%, 24%, 0%)
  darkseagreen2	cmyk(24%, 0%, 24%, 7%)	 	darkseagreen3	cmyk(24%, 0%, 24%, 20%)	 	darkseagreen (SVG)	cmyk(24%, 0%, 24%, 26%)
  darkseagreen4	cmyk(24%, 0%, 24%, 45%)	 	olivedrab4	cmyk(24%, 0%, 76%, 45%)	 	light steelblue	cmyk(24%, 24%, 0%, 26%)
  wavecrest	cmyk(25%, 0%, 2%, 20%)	 	liberty	cmyk(25%, 0%, 5%, 14%)	 	blue fern	cmyk(25%, 0%, 15%, 39%)
  eton blue	cmyk(25%, 0%, 19%, 22%)	 	mint green	cmyk(25%, 0%, 20%, 1%)	 	yellowgreen2	cmyk(25%, 0%, 75%, 20%)
  olivedrab (SVG)	cmyk(25%, 0%, 75%, 44%)	 	olivedrab1	cmyk(25%, 0%, 76%, 0%)	 	olivedrab2	cmyk(25%, 0%, 76%, 7%)
  yellowgreen (SVG)	cmyk(25%, 0%, 76%, 20%)	 	light blue1	cmyk(25%, 6%, 0%, 0%)	 	light blue2	cmyk(25%, 6%, 0%, 7%)
  lightblue (SVG)	cmyk(25%, 6%, 0%, 10%)	 	light blue3	cmyk(25%, 6%, 0%, 20%)	 	light blue4	cmyk(25%, 6%, 0%, 45%)
  violet flower	cmyk(25%, 63%, 0%, 0%)	 	darkorchid (SVG)	cmyk(25%, 75%, 0%, 20%)	 	darkslateblue	cmyk(25%, 75%, 0%, 44%)
  darkorchid1	cmyk(25%, 76%, 0%, 0%)	 	darkorchid2	cmyk(25%, 76%, 0%, 7%)	 	darkorchid3	cmyk(25%, 76%, 0%, 20%)
  darkorchid	cmyk(25%, 76%, 0%, 20%)	 	darkorchid4	cmyk(25%, 76%, 0%, 45%)	 	paleturquoise (SVG)	cmyk(26%, 0%, 0%, 7%)
  turquoise	cmyk(26%, 0%, 0%, 8%)	 	wet moss	cmyk(26%, 0%, 50%, 68%)	 	fenway grass	cmyk(26%, 0%, 52%, 56%)
  paleturquoise1 (Hex3)	cmyk(27%, 0%, 0%, 0%)	 	paleturquoise2	cmyk(27%, 0%, 0%, 7%)	 	paleturquoise3	cmyk(27%, 0%, 0%, 20%)
  paleturquoise4	cmyk(27%, 0%, 0%, 45%)	 	pumice	cmyk(27%, 0%, 16%, 36%)	 	palm	cmyk(27%, 0%, 50%, 49%)
  green ash	cmyk(28%, 0%, 6%, 44%)	 	pastel green	cmyk(28%, 0%, 19%, 20%)	 	Coke bottle	cmyk(28%, 0%, 19%, 34%)
  fraser fir	cmyk(28%, 0%, 25%, 58%)	 	spinach	cmyk(28%, 0%, 42%, 64%)	 	mtn dew bottle	cmyk(29%, 0%, 52%, 52%)
  romaine lettuce	cmyk(29%, 0%, 58%, 67%)	 	pea	cmyk(30%, 0%, 59%, 33%)	 	wild violet	cmyk(30%, 94%, 0%, 27%)
  darkviolet (SVG)	cmyk(30%, 100%, 0%, 17%)	 	putting	cmyk(31%, 0%, 34%, 40%)	 	frog	cmyk(31%, 0%, 44%, 25%)
  light skyblue1	cmyk(31%, 11%, 0%, 0%)	 	light skyblue2	cmyk(31%, 11%, 0%, 7%)	 	light skyblue3	cmyk(31%, 11%, 0%, 20%)
  light skyblue4	cmyk(31%, 12%, 0%, 45%)	 	cerulean blue	cmyk(31%, 13%, 0%, 11%)	 	blue tuna	cmyk(31%, 18%, 0%, 41%)
  bluegrass	cmyk(32%, 0%, 11%, 56%)	 	100 euro	cmyk(32%, 0%, 37%, 22%)	 	forestgreen2	cmyk(32%, 0%, 54%, 51%)
  greenyellow (SVG)	cmyk(32%, 0%, 82%, 0%)	 	isle royale greenstone	cmyk(33%, 0%, 17%, 61%)	 	obsidian	cmyk(33%, 0%, 26%, 64%)
  greenyellow	cmyk(33%, 0%, 49%, 14%)	 	noble fir	cmyk(33%, 0%, 51%, 58%)	 	periwinkle (Hex3)	cmyk(33%, 33%, 0%, 0%)
  medium purple1	cmyk(33%, 49%, 0%, 0%)	 	medium purple2	cmyk(33%, 49%, 0%, 7%)	 	mediumpurple (SVG)	cmyk(33%, 49%, 0%, 14%)
  medium purple3	cmyk(33%, 49%, 0%, 20%)	 	medium purple4	cmyk(33%, 49%, 0%, 45%)	 	purple	cmyk(33%, 87%, 0%, 6%)
  concord grape	cmyk(33%, 99%, 0%, 40%)	 	purple6 (Hex3)	cmyk(33%, 100%, 0%, 0%)	 	light blue	cmyk(34%, 0%, 0%, 15%)
  green stamp	cmyk(34%, 0%, 28%, 52%)	 	douglas fir	cmyk(34%, 0%, 55%, 62%)	 	kakapo	cmyk(34%, 0%, 69%, 56%)
  lindsay eyes	cmyk(34%, 6%, 0%, 40%)	 	greencopper	cmyk(35%, 0%, 7%, 50%)	 	lampblack	cmyk(35%, 0%, 17%, 72%)
  green apple	cmyk(35%, 0%, 67%, 41%)	 	sgilight blue	cmyk(35%, 18%, 0%, 25%)	 	green visor	cmyk(36%, 0%, 16%, 53%)
  scotland pound	cmyk(36%, 0%, 27%, 56%)	 	green moth	cmyk(36%, 0%, 45%, 25%)	 	tree moss	cmyk(36%, 0%, 68%, 38%)
  darkgreencopper	cmyk(37%, 0%, 7%, 54%)	 	shamrock	cmyk(37%, 0%, 25%, 60%)	 	green soap	cmyk(37%, 0%, 42%, 13%)
  olive3b	cmyk(37%, 0%, 54%, 63%)	 	limerind	cmyk(37%, 0%, 71%, 69%)	 	old copper	cmyk(37%, 3%, 0%, 28%)
  lake huron	cmyk(37%, 16%, 0%, 42%)	 	blue corn	cmyk(37%, 21%, 0%, 68%)	 	palegreen (SVG)	cmyk(39%, 0%, 39%, 2%)
  light green (SVG)	cmyk(39%, 0%, 39%, 7%)	 	green grass of home	cmyk(39%, 0%, 45%, 64%)	 	royal palm	cmyk(39%, 0%, 63%, 59%)
  fenway monster	cmyk(39%, 2%, 0%, 52%)	 	blue shark	cmyk(39%, 13%, 0%, 32%)	 	blue cow	cmyk(39%, 23%, 0%, 12%)
  blue jeans	cmyk(39%, 24%, 0%, 58%)	 	purple1	cmyk(39%, 81%, 0%, 0%)	 	blueviolet (SVG)	cmyk(39%, 81%, 0%, 11%)
  purple3	cmyk(39%, 81%, 0%, 20%)	 	purple4	cmyk(39%, 81%, 0%, 45%)	 	purple2	cmyk(39%, 82%, 0%, 7%)
  cadetblue	cmyk(40%, 0%, 0%, 38%)	 	green agate	cmyk(40%, 0%, 2%, 55%)	 	palegreen1	cmyk(40%, 0%, 40%, 0%)
  palegreen3	cmyk(40%, 0%, 40%, 20%)	 	palegreen4	cmyk(40%, 0%, 40%, 45%)	 	night vision	cmyk(40%, 0%, 45%, 20%)
  terreverte	cmyk(40%, 0%, 84%, 63%)	 	cadetblue1	cmyk(40%, 4%, 0%, 0%)	 	cadetblue2	cmyk(40%, 4%, 0%, 7%)
  cadetblue3	cmyk(40%, 4%, 0%, 20%)	 	cadetblue4	cmyk(40%, 4%, 0%, 45%)	 	LCD dark	cmyk(40%, 11%, 0%, 47%)
  darkslategray1	cmyk(41%, 0%, 0%, 0%)	 	darkslategray2	cmyk(41%, 0%, 0%, 7%)	 	darkslategray3	cmyk(41%, 0%, 0%, 20%)
  darkslategray4	cmyk(41%, 0%, 0%, 45%)	 	darkslategrey (SVG)	cmyk(41%, 0%, 0%, 69%)	 	darkslategray (SVG)	cmyk(41%, 0%, 0%, 69%)
  medium seagreen	cmyk(41%, 0%, 41%, 56%)	 	darkgreen	cmyk(41%, 0%, 41%, 69%)	 	cadetblue (SVG)	cmyk(41%, 1%, 0%, 37%)
  lake superior	cmyk(41%, 22%, 0%, 47%)	 	nikko blue	cmyk(41%, 36%, 0%, 13%)	 	cornflowerblue	cmyk(41%, 41%, 0%, 56%)
  midnightblue	cmyk(41%, 41%, 0%, 69%)	 	green party	cmyk(42%, 0%, 26%, 58%)	 	emerald	cmyk(42%, 0%, 36%, 39%)
  green algae	cmyk(42%, 0%, 43%, 33%)	 	lake erie	cmyk(42%, 21%, 0%, 35%)	 	seurat blue	cmyk(42%, 22%, 0%, 23%)
  indigo (SVG)	cmyk(42%, 100%, 0%, 49%)	 	cool mint	cmyk(43%, 0%, 1%, 0%)	 	sgichartreuse	cmyk(43%, 0%, 43%, 22%)
  circuit board	cmyk(43%, 0%, 60%, 60%)	 	skyblue (SVG)	cmyk(43%, 12%, 0%, 8%)	 	sgislate blue	cmyk(43%, 43%, 0%, 22%)
  presidential blue	cmyk(43%, 49%, 0%, 67%)	 	green scrubs	cmyk(44%, 0%, 8%, 44%)	 	blueberry	cmyk(44%, 23%, 0%, 18%)
  cooler	cmyk(45%, 0%, 10%, 71%)	 	holly	cmyk(45%, 0%, 85%, 49%)	 	malta blue	cmyk(45%, 20%, 0%, 42%)
  cat eye	cmyk(45%, 24%, 0%, 13%)	 	indigo	cmyk(45%, 90%, 0%, 67%)	 	packer green	cmyk(46%, 0%, 21%, 76%)
  cinnabargreen	cmyk(46%, 0%, 77%, 30%)	 	lightskyblue (SVG)	cmyk(46%, 18%, 0%, 2%)	 	mediterranean	cmyk(47%, 0%, 8%, 54%)
  green gables	cmyk(47%, 0%, 8%, 54%)	 	neon green	cmyk(47%, 0%, 82%, 4%)	 	blue sponge	cmyk(47%, 18%, 0%, 31%)
  skyblue1	cmyk(47%, 19%, 0%, 0%)	 	skyblue2	cmyk(47%, 19%, 0%, 7%)	 	skyblue3	cmyk(47%, 19%, 0%, 20%)
  skyblue4	cmyk(47%, 19%, 0%, 45%)	 	blue whale	cmyk(48%, 21%, 0%, 50%)	 	richblue	cmyk(48%, 48%, 0%, 33%)
  light slateblue	cmyk(48%, 56%, 0%, 0%)	 	mediumslateblue (SVG)	cmyk(48%, 56%, 0%, 7%)	 	slateblue (SVG)	cmyk(48%, 56%, 0%, 20%)
  darkslateblue (SVG)	cmyk(48%, 56%, 0%, 45%)	 	medium turquoise	cmyk(49%, 0%, 0%, 14%)	 	ooze	cmyk(49%, 0%, 23%, 52%)
  aquamarine	cmyk(49%, 0%, 33%, 14%)	 	blue mist	cmyk(49%, 18%, 0%, 1%)	 	darkturquoise	cmyk(49%, 33%, 0%, 14%)
  blueberry fresh	cmyk(49%, 35%, 0%, 32%)	 	slateblue1	cmyk(49%, 56%, 0%, 0%)	 	slateblue2	cmyk(49%, 57%, 0%, 7%)
  slateblue3	cmyk(49%, 57%, 0%, 20%)	 	slateblue4	cmyk(49%, 57%, 0%, 45%)	 	aqua (Safe Hex3)	cmyk(50%, 0%, 0%, 20%)
  aquamarine (SVG)	cmyk(50%, 0%, 17%, 0%)	 	aquamarine2	cmyk(50%, 0%, 17%, 7%)	 	mediumaquamarine (SVG)	cmyk(50%, 0%, 17%, 20%)
  aquamarine4	cmyk(50%, 0%, 17%, 45%)	 	chartreuse (SVG)	cmyk(50%, 0%, 100%, 0%)	 	chartreuse2	cmyk(50%, 0%, 100%, 7%)
  chartreuse3	cmyk(50%, 0%, 100%, 20%)	 	chartreuse4	cmyk(50%, 0%, 100%, 45%)	 	blue stone	cmyk(50%, 28%, 0%, 38%)
  medium slateblue2	cmyk(50%, 100%, 0%, 0%)	 	leaf	cmyk(51%, 0%, 67%, 32%)	 	lawngreen (SVG)	cmyk(51%, 0%, 100%, 1%)
  pacific blue	cmyk(51%, 19%, 0%, 58%)	 	aquamarine	cmyk(51%, 25%, 0%, 37%)	 	forget me nots	cmyk(51%, 29%, 0%, 0%)
  curacao	cmyk(51%, 52%, 0%, 27%)	 	dress blue	cmyk(51%, 59%, 0%, 53%)	 	blue deep	cmyk(52%, 97%, 0%, 55%)
  cucumber	cmyk(53%, 0%, 32%, 64%)	 	lake ontario	cmyk(53%, 31%, 0%, 36%)	 	park bench	cmyk(54%, 0%, 32%, 61%)
  green pepper	cmyk(54%, 0%, 98%, 51%)	 	blue ice	cmyk(54%, 25%, 0%, 2%)	 	blue green algae	cmyk(55%, 0%, 14%, 48%)
  old money	cmyk(55%, 0%, 37%, 56%)	 	pollock blue	cmyk(55%, 35%, 0%, 33%)	 	neptune	cmyk(55%, 36%, 0%, 5%)
  green lantern	cmyk(56%, 0%, 60%, 45%)	 	swimming pool	cmyk(56%, 3%, 0%, 7%)	 	army men	cmyk(57%, 0%, 26%, 54%)
  fresh green	cmyk(57%, 0%, 28%, 15%)	 	viridianlight	cmyk(57%, 0%, 56%, 0%)	 	carolina blue	cmyk(57%, 19%, 0%, 24%)
  liz eyes	cmyk(57%, 21%, 0%, 55%)	 	blue bird	cmyk(57%, 33%, 0%, 33%)	 	blue lagoon	cmyk(58%, 0%, 10%, 28%)
  cobaltgreen	cmyk(58%, 0%, 56%, 43%)	 	cornflowerblue (SVG)	cmyk(58%, 37%, 0%, 7%)	 	green MM	cmyk(59%, 0%, 58%, 28%)
  grass	cmyk(59%, 0%, 73%, 26%)	 	kelly	cmyk(59%, 0%, 88%, 27%)	 	surf	cmyk(59%, 14%, 0%, 4%)
  lake michigan	cmyk(59%, 14%, 0%, 24%)	 	blue grapes	cmyk(59%, 49%, 0%, 44%)	 	green taxi	cmyk(60%, 0%, 51%, 38%)
  wasabi (Safe Hex3)	cmyk(60%, 0%, 60%, 0%)	 	neon blue	cmyk(60%, 22%, 0%, 0%)	 	tropical blue	cmyk(60%, 28%, 0%, 4%)
  cobalt (Safe Hex3)	cmyk(60%, 60%, 0%, 0%)	 	blue safe (Safe Hex3)	cmyk(60%, 100%, 0%, 0%)	 	sgiteal	cmyk(61%, 0%, 0%, 44%)
  clover	cmyk(61%, 0%, 47%, 37%)	 	steelblue1	cmyk(61%, 28%, 0%, 0%)	 	steelblue2	cmyk(61%, 28%, 0%, 7%)
  steelblue3	cmyk(61%, 28%, 0%, 20%)	 	steelblue (SVG)	cmyk(61%, 28%, 0%, 29%)	 	steelblue4	cmyk(61%, 28%, 0%, 45%)
  denim	cmyk(61%, 33%, 0%, 33%)	 	chemical suit	cmyk(61%, 36%, 0%, 10%)	 	blue train	cmyk(61%, 41%, 0%, 42%)
  la maison bleue	cmyk(62%, 31%, 0%, 0%)	 	wales	cmyk(63%, 0%, 64%, 21%)	 	sapgreen	cmyk(63%, 0%, 84%, 50%)
  green LED	cmyk(63%, 0%, 96%, 1%)	 	greek roof	cmyk(63%, 34%, 0%, 37%)	 	natural gas	cmyk(63%, 41%, 0%, 4%)
  masters jacket	cmyk(64%, 0%, 13%, 75%)	 	octopus	cmyk(64%, 0%, 36%, 43%)	 	cobalt	cmyk(64%, 48%, 0%, 33%)
  natural turquoise	cmyk(65%, 0%, 6%, 24%)	 	huntergreen	cmyk(65%, 0%, 65%, 63%)	 	blue spider	cmyk(65%, 36%, 0%, 57%)
  blue ridge mtns	cmyk(65%, 37%, 0%, 19%)	 	big blue bus	cmyk(65%, 39%, 0%, 35%)	 	mediumturquoise (SVG)	cmyk(66%, 0%, 2%, 18%)
  mediumseagreen (SVG)	cmyk(66%, 0%, 37%, 30%)	 	green line	cmyk(66%, 0%, 43%, 42%)	 	blue pill	cmyk(66%, 39%, 0%, 7%)
  seagreen (SVG)	cmyk(67%, 0%, 37%, 45%)	 	seagreen1	cmyk(67%, 0%, 38%, 0%)	 	seagreen2	cmyk(67%, 0%, 38%, 7%)
  seagreen3	cmyk(67%, 0%, 38%, 20%)	 	blue angels	cmyk(67%, 39%, 0%, 49%)	 	Nerf green	cmyk(68%, 0%, 94%, 11%)
  YInMn blue	cmyk(68%, 44%, 0%, 44%)	 	electric turquoise	cmyk(69%, 0%, 19%, 9%)	 	go	cmyk(69%, 0%, 34%, 16%)
  delft	cmyk(69%, 55%, 0%, 58%)	 	atlantic green	cmyk(70%, 0%, 8%, 44%)	 	blue bucket	cmyk(70%, 36%, 0%, 4%)
  neonblue	cmyk(70%, 70%, 0%, 0%)	 	turquoise (SVG)	cmyk(71%, 0%, 7%, 12%)	 	aquaman	cmyk(71%, 0%, 48%, 26%)
  mailbox	cmyk(71%, 40%, 0%, 35%)	 	st louis blues	cmyk(71%, 46%, 0%, 41%)	 	royalblue (SVG)	cmyk(71%, 53%, 0%, 12%)
  aquarium	cmyk(72%, 0%, 12%, 33%)	 	nypd blue	cmyk(72%, 11%, 0%, 20%)	 	royalblue1	cmyk(72%, 54%, 0%, 0%)
  royalblue2	cmyk(72%, 54%, 0%, 7%)	 	royalblue3	cmyk(72%, 54%, 0%, 20%)	 	royalblue4	cmyk(72%, 54%, 0%, 45%)
  pabst blue	cmyk(72%, 60%, 0%, 44%)	 	6 ball	cmyk(73%, 0%, 17%, 61%)	 	blue velvet	cmyk(73%, 59%, 0%, 68%)
  pool table	cmyk(74%, 0%, 58%, 27%)	 	caribbean	cmyk(74%, 24%, 0%, 2%)	 	pacific green	cmyk(75%, 0%, 8%, 14%)
  medium aquamarine2	cmyk(75%, 0%, 25%, 20%)	 	seagreen	cmyk(75%, 0%, 27%, 44%)	 	peacock	cmyk(75%, 20%, 0%, 21%)
  summersky	cmyk(75%, 21%, 0%, 13%)	 	skyblue6	cmyk(75%, 25%, 0%, 20%)	 	steelblue	cmyk(75%, 25%, 0%, 44%)
  medium blue	cmyk(75%, 75%, 0%, 20%)	 	navyblue	cmyk(75%, 75%, 0%, 44%)	 	indigo2	cmyk(76%, 0%, 24%, 47%)
  medium aquamarine3	cmyk(76%, 0%, 25%, 20%)	 	limegreen (SVG)	cmyk(76%, 0%, 76%, 20%)	 	forestgreen (SVG)	cmyk(76%, 0%, 76%, 45%)
  parrot	cmyk(76%, 45%, 0%, 14%)	 	medium blue2	cmyk(76%, 76%, 0%, 20%)	 	emeraldgreen2	cmyk(77%, 0%, 29%, 32%)
  blue line	cmyk(77%, 27%, 0%, 13%)	 	metallic mint	cmyk(78%, 0%, 0%, 1%)	 	midnightblue (SVG)	cmyk(78%, 78%, 0%, 56%)
  parrotgreen (Safe Hex3)	cmyk(80%, 0%, 80%, 0%)	 	royalblue (Safe Hex3)	cmyk(80%, 80%, 0%, 0%)	 	cornflower (Safe Hex3)	cmyk(80%, 100%, 0%, 0%)
  alaska sky	cmyk(81%, 55%, 0%, 45%)	 	lightseagreen (SVG)	cmyk(82%, 0%, 4%, 30%)	 	bottle green	cmyk(82%, 0%, 66%, 36%)
  stained glass	cmyk(82%, 78%, 0%, 0%)	 	emerald city	cmyk(83%, 0%, 17%, 25%)	 	gummi green	cmyk(83%, 0%, 77%, 17%)
  garden hose	cmyk(87%, 0%, 26%, 44%)	 	ultramarine	cmyk(87%, 93%, 0%, 44%)	 	malachite	cmyk(88%, 0%, 13%, 50%)
  dodgerblue3	cmyk(88%, 43%, 0%, 20%)	 	dodgerblue (SVG)	cmyk(88%, 44%, 0%, 0%)	 	dodgerblue2	cmyk(88%, 44%, 0%, 7%)
  dodgerblue4	cmyk(88%, 44%, 0%, 45%)	 	peafowl	cmyk(88%, 49%, 0%, 5%)	 	banker's lamp	cmyk(90%, 0%, 59%, 45%)
  indigo dye	cmyk(91%, 43%, 0%, 45%)	 	ulysses butterfly	cmyk(92%, 59%, 0%, 4%)	 	turquoise	cmyk(93%, 0%, 21%, 13%)
  diamond blue	cmyk(94%, 18%, 0%, 9%)	 	sea green	cmyk(95%, 0%, 2%, 48%)	 	permanent green	cmyk(95%, 0%, 79%, 21%)
  police strobe	cmyk(96%, 29%, 0%, 0%)	 	manganeseblue	cmyk(98%, 0%, 6%, 34%)	 	teal LED	cmyk(98%, 7%, 0%, 0%)
  indiglo	cmyk(98%, 9%, 0%, 0%)	 	cerulean	cmyk(98%, 10%, 0%, 20%)	 	mouthwash	cmyk(99%, 0%, 5%, 23%)
  picasso blue	cmyk(99%, 53%, 0%, 1%)	 	aqua (Safe 16 SVG Hex3)	cmyk(100%, 0%, 0%, 0%)	 	cyan (Safe 16=aqua SVG Hex3)	cmyk(100%, 0%, 0%, 0%)
  cyan2 (Hex3)	cmyk(100%, 0%, 0%, 7%)	 	cyan3	cmyk(100%, 0%, 0%, 20%)	 	darkcyan (SVG)	cmyk(100%, 0%, 0%, 45%)
  teal (16 SVG)	cmyk(100%, 0%, 0%, 50%)	 	light teal (Safe Hex3)	cmyk(100%, 0%, 20%, 0%)	 	sign green	cmyk(100%, 0%, 21%, 58%)
  turquoiseblue	cmyk(100%, 0%, 30%, 22%)	 	seagreen (Hex3)	cmyk(100%, 0%, 33%, 0%)	 	mediumspringgreen (SVG)	cmyk(100%, 0%, 38%, 2%)
  springgreen (SVG)	cmyk(100%, 0%, 50%, 0%)	 	springgreen2	cmyk(100%, 0%, 50%, 7%)	 	springgreen3	cmyk(100%, 0%, 50%, 20%)
  springgreen4	cmyk(100%, 0%, 50%, 45%)	 	starbucks (Safe Hex3)	cmyk(100%, 0%, 50%, 60%)	 	emeraldgreen	cmyk(100%, 0%, 57%, 21%)
  neonavocado (Safe Hex3)	cmyk(100%, 0%, 60%, 0%)	 	truegreen	cmyk(100%, 0%, 71%, 31%)	 	celtics	cmyk(100%, 0%, 71%, 62%)
  springgreen (Safe Hex3)	cmyk(100%, 0%, 80%, 0%)	 	lime (Safe 16 SVG Hex3)	cmyk(100%, 0%, 100%, 0%)	 	green2 (Hex3)	cmyk(100%, 0%, 100%, 7%)
  green3	cmyk(100%, 0%, 100%, 20%)	 	irish flag (Safe Hex3)	cmyk(100%, 0%, 100%, 40%)	 	green4	cmyk(100%, 0%, 100%, 45%)
  green (16 SVG)	cmyk(100%, 0%, 100%, 50%)	 	darkgreen (SVG)	cmyk(100%, 0%, 100%, 61%)	 	dumpster	cmyk(100%, 0%, 100%, 69%)
  pinegreen (Safe Hex3)	cmyk(100%, 0%, 100%, 80%)	 	darkturquoise (SVG)	cmyk(100%, 1%, 0%, 18%)	 	turquoise1	cmyk(100%, 4%, 0%, 0%)
  turquoise2	cmyk(100%, 4%, 0%, 7%)	 	turquoise3	cmyk(100%, 4%, 0%, 20%)	 	turquoise4	cmyk(100%, 4%, 0%, 45%)
  deepskyblue (SVG)	cmyk(100%, 25%, 0%, 0%)	 	deepskyblue2	cmyk(100%, 25%, 0%, 7%)	 	skyblue5 (Safe Hex3)	cmyk(100%, 25%, 0%, 20%)
  deepskyblue3	cmyk(100%, 25%, 0%, 20%)	 	deepskyblue4	cmyk(100%, 25%, 0%, 45%)	 	topaz	cmyk(100%, 32%, 0%, 12%)
  slateblue	cmyk(100%, 50%, 0%, 0%)	 	sign blue	cmyk(100%, 53%, 0%, 47%)	 	ty nant	cmyk(100%, 72%, 0%, 2%)
  cichlid	cmyk(100%, 76%, 0%, 0%)	 	blue (Safe 16 SVG Hex3)	cmyk(100%, 100%, 0%, 0%)	 	blue2 (Hex3)	cmyk(100%, 100%, 0%, 7%)
  mediumblue (SVG)	cmyk(100%, 100%, 0%, 20%)	 	newmidnightblue	cmyk(100%, 100%, 0%, 39%)	 	darkblue (SVG)	cmyk(100%, 100%, 0%, 45%)
  navy (16 SVG)	cmyk(100%, 100%, 0%, 50%)	 	midnightblue2 (Safe Hex3)	cmyk(100%, 100%, 0%, 80%)
  """

  cmyk_colors =
    cmyk_color_data
    |> String.replace("\r\n", "\n")
    |> String.replace("\n", "\t \t")
    |> String.split("\t \t")

  @cmyk_colors cmyk_colors

  def cmyk_colors(), do: @cmyk_colors

  css_color_data = """
  AliceBlue	#F0F8FF	240, 248, 255
  AntiqueWhite	#FAEBD7	250, 235, 215
  Aqua	#00FFFF	0, 255, 255
  Aquamarine	#7FFFD4	127, 255, 212
  Azure	#F0FFFF	240, 255, 255
  Beige	#F5F5DC	245, 245, 220
  Bisque	#FFE4C4	255, 228, 196
  Black	#000000	0, 0, 0
  BlanchedAlmond	#FFEBCD	255, 235, 205
  Blue	#0000FF	0, 0, 255
  BlueViolet	#8A2BE2	138, 43, 226
  Brown	#A52A2A	165, 42, 42
  BurlyWood	#DEB887	222, 184, 135
  CadetBlue	#5F9EA0	95, 158, 160
  Chartreuse	#7FFF00	127, 255, 0
  Chocolate	#D2691E	210, 105, 30
  Coral	#FF7F50	255, 127, 80
  CornflowerBlue	#6495ED	100, 149, 237
  Cornsilk	#FFF8DC	255, 248, 220
  Crimson	#DC143C	220, 20, 60
  Cyan	#00FFFF	0, 255, 255
  DarkBlue	#00008B	0, 0, 139
  DarkCyan	#008B8B	0, 139, 139
  DarkGoldenrod	#B8860B	184, 134, 11
  DarkGray	#A9A9A9	169, 169, 169
  DarkGreen	#006400	0, 100, 0
  DarkGrey	#A9A9A9	169, 169, 169
  DarkKhaki	#BDB76B	189, 183, 107
  DarkMagenta	#8B008B	139, 0, 139
  DarkOliveGreen	#556B2F	85, 107, 47
  DarkOrange	#FF8C00	255, 140, 0
  DarkOrchid	#9932CC	153, 50, 204
  DarkRed	#8B0000	139, 0, 0
  DarkSalmon	#E9967A	233, 150, 122
  DarkSeaGreen	#8FBC8F	143, 188, 143
  DarkSlateBlue	#483D8B	72, 61, 139
  DarkSlateGray	#2F4F4F	47, 79, 79
  DarkSlateGrey	#2F4F4F	47, 79, 79
  DarkTurquoise	#00CED1	0, 206, 209
  DarkViolet	#9400D3	148, 0, 211
  DeepPink	#FF1493	255, 20, 147
  DeepSkyBlue	#00BFFF	0, 191, 255
  DimGray	#696969	105, 105, 105
  DodgerBlue	#1E90FF	30, 144, 255
  FireBrick	#B22222	178, 34, 34
  FloralWhite	#FFFAF0	255, 250, 240
  ForestGreen	#228B22	34, 139, 34
  Fuchsia	#FF00FF	255, 0, 255
  Gainsboro	#DCDCDC	220, 220, 220
  GhostWhite	#F8F8FF	248, 248, 255
  Gold	#FFD700	255, 215, 0
  Goldenrod	#DAA520	218, 165, 32
  Gray	#808080	128, 128, 128
  Green	#008000	0, 128, 0
  GreenYellow	#ADFF2F	173, 255, 47
  Grey	#808080	128, 128, 128
  Honeydew	#F0FFF0	240, 255, 240
  HotPink	#FF69B4	255, 105, 180
  IndianRed	#CD5C5C	205, 92, 92
  Indigo	#4B0082	75, 0, 130
  Ivory	#FFFFF0	255, 255, 240
  Khaki	#F0E68C	240, 230, 140
  Lavender	#E6E6FA	230, 230, 250
  LavenderBlush	#FFF0F5	255, 240, 245
  LawnGreen	#7CFC00	124, 252, 0
  LemonChiffon	#FFFACD	255, 250, 205
  LightBlue	#ADD8E6	173, 216, 230
  LightCoral	#F08080	240, 128, 128
  LightCyan	#E0FFFF	224, 255, 255
  LightGoldenrodYellow	#FAFAD2	250, 250, 210
  LightGray	#D3D3D3	211, 211, 211
  LightGreen	#90EE90	144, 238, 144
  LightGrey	#D3D3D3	211, 211, 211
  LightPink	#FFB6C1	255, 182, 193
  LightSalmon	#FFA07A	255, 160, 122
  LightSeaGreen	#20B2AA	32, 178, 170
  LightSkyBlue	#87CEFA	135, 206, 250
  LightSlateGray	#778899	119, 136, 153
  LightSlateGrey	#778899	119, 136, 153
  LightSteelBlue	#B0C4DE	176, 196, 222
  LightYellow	#FFFFE0	255, 255, 224
  Lime	#00FF00	0, 255, 0
  LimeGreen	#32CD32	50, 205, 50
  Linen	#FAF0E6	250, 240, 230
  Magenta	#FF00FF	255, 0, 255
  Maroon	#800000	128, 0, 0
  MediumAquamarine	#66CDAA	102, 205, 170
  MediumBlue	#0000CD	0, 0, 205
  MediumOrchid	#BA55D3	186, 85, 211
  MediumPurple	#9370DB	147, 112, 219
  MediumSeaGreen	#3CB371	60, 179, 113
  MediumSlateBlue	#7B68EE	123, 104, 238
  MediumSpringGreen	#00FA9A	0, 250, 154
  MediumTurquoise	#48D1CC	72, 209, 204
  MediumVioletRed	#C71585	199, 21, 133
  MidnightBlue	#191970	25, 25, 112
  MintCream	#F5FFFA	245, 255, 250
  MistyRose	#FFE4E1	255, 228, 225
  Moccasin	#FFE4B5	255, 228, 181
  NavajoWhite	#FFDEAD	255, 222, 173
  Navy	#000080	0, 0, 128
  OldLace	#FDF5E6	253, 245, 230
  Olive	#808000	128, 128, 0
  OliveDrab	#6B8E23	107, 142, 35
  Orange	#FFA500	255, 165, 0
  OrangeRed	#FF4500	255, 69, 0
  Orchid	#DA70D6	218, 112, 214
  PaleGoldenrod	#EEE8AA	238, 232, 170
  PaleGreen	#98FB98	152, 251, 152
  PaleTurquoise	#AFEEEE	175, 238, 238
  PaleVioletRed	#DB7093	219, 112, 147
  PapayaWhip	#FFEFD5	255, 239, 213
  PeachPuff	#FFDAB9	255, 218, 185
  Peru	#CD853F	205, 133, 63
  Pink	#FFC0CB	255, 192, 203
  Plum	#DDA0DD	221, 160, 221
  PowderBlue	#B0E0E6	176, 224, 230
  Purple	#800080	128, 0, 128
  Rebeccapurple	#663399	102, 51, 153
  Red	#FF0000	255, 0, 0
  RosyBrown	#BC8F8F	188, 143, 143
  RoyalBlue	#4169E1	65, 105, 225
  SaddleBrown	#8B4513	139, 69, 19
  Salmon	#FA8072	250, 128, 114
  SandyBrown	#F4A460	244, 164, 96
  SeaGreen	#2E8B57	46, 139, 87
  Seashell	#FFF5EE	255, 245, 238
  Sienna	#A0522D	160, 82, 45
  Silver	#C0C0C0	192, 192, 192
  SkyBlue	#87CEEB	135, 206, 235
  SlateBlue	#6A5ACD	106, 90, 205
  SlateGray	#708090	112, 128, 144
  SlateGrey	#708090	112, 128, 144
  Snow	#FFFAFA	255, 250, 250
  SpringGreen	#00FF7F	0, 255, 127
  SteelBlue	#4682B4	70, 130, 180
  Tan	#D2B48C	210, 180, 140
  Teal	#008080	0, 128, 128
  Thistle	#D8BFD8	216, 191, 216
  Tomato	#FF6347	255, 99, 71
  Turquoise	#40E0D0	64, 224, 208
  Violet	#EE82EE	238, 130, 238
  Wheat	#F5DEB3	245, 222, 179
  White	#FFFFFF	255, 255, 255
  WhiteSmoke	#F5F5F5	245, 245, 245
  Yellow	#FFFF00	255, 255, 0
  YellowGreen	#9ACD32	154, 205, 50
  """

  parse_int! = fn text ->
    {integer, ""} = Integer.parse(text)
    integer
  end

  parse_css_color = fn line ->
    [name, _hex, rbg] = String.split(line, "\t")
    [r, g, b] = rbg |> String.split(", ") |> Enum.map(parse_int!)

    name_as_atom =
      name
      |> Macro.underscore()
      |> String.to_atom()

    {name_as_atom, {r, g, b}}
  end

  css_colors =
    css_color_data
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(fn line -> line == "" end)
    |> Enum.map(parse_css_color)

  @css_colors css_colors

  # TODO: add some accessibility features to the color boxes

  defmacro build_css_color_functions() do
    definitions =
      for {name, {r, g, b}} <- @css_colors do
        color_name =
          name
          |> to_string()
          |> String.replace("_", " ")

        color_block = """
        <div \
        style="margin-left:1.3em;width:8em;height:1.4em;\
        border-radius:4px;background:rgb(#{r},#{g},#{b})">\
        </div>\
        """

        color_block_alphas =
          for alpha <- [1.0, 0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125] do
            """
            <div \
            style="padding:5px;margin-left:0.8em;width:6em;height:1.4em;\
            display:inline;border-radius:4px;background:rgba(#{r},#{g},#{b},#{alpha})">\
            #{Formatter.rounded_float(alpha, 3)}</div>\
            """
          end
          |> Enum.join("\n")

        quote do
          @doc """
          Opaque RGB color for *#{unquote(color_name)}*,
          as defined by the CSS3 standard.
          #{unquote(color_block)}
          """

          @spec unquote(name)() :: t()

          def unquote(name)() do
            %__MODULE__{
              red: unquote(r),
              green: unquote(g),
              blue: unquote(b),
              alpha: 255
            }
          end

          @doc """
          Semi-transparent RGB color for #{unquote(color_name)}
          as defined by the CSS3 standard.
          
          The value of `alpha` may be either an *integer* between
          0 and 255 or a *float* between 0.0 and 1.0.
          
          Color according to the value of `alpha`:
          #{unquote(color_block_alphas)}
          """

          @spec unquote(name)(non_neg_integer() | float()) :: t()

          def unquote(name)(alpha) when is_float(alpha) and alpha >= 0 and alpha <= 1.0 do
            # Convert an integer
            integer_alpha = round(alpha * 255)

            %__MODULE__{
              red: unquote(r),
              green: unquote(g),
              blue: unquote(b),
              alpha: integer_alpha
            }
          end

          def unquote(name)(alpha) when is_integer(alpha) and alpha >= 0 and alpha <= 255 do
            %__MODULE__{
              red: unquote(r),
              green: unquote(g),
              blue: unquote(b),
              alpha: alpha
            }
          end
        end
      end

    quote do
      (unquote_splicing(definitions))
    end
  end
end
