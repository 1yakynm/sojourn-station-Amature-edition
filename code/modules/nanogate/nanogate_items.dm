// Here is where we store the items made by the nanogate organ.
/obj/item/rig/nanite
	name = "nanite suit control module"
	desc = "A lighter, less armoured rig suit made from nanites and attached to someone's spine."
	icon_state = "ihs_rig_old"
	suit_type = "nanite suit"
	armor = list(
		melee = 30,
		bullet = 30,
		energy = 30,
		bomb = 25,
		bio = 100,
		rad = 100
	) // the suit is less armored than a psion suit but provides alot more utility. -Kaz.
	emp_protection = 10
	slowdown = 0
	item_flags = STOPPRESSUREDAMAGE | THICKMATERIAL | DRAG_AND_DROP_UNEQUIP | EQUIP_SOUNDS
	offline_slowdown = 0
	offline_vision_restriction = 0
	drain = 2
	canremove = FALSE // It is attached to your back

	chest_type = /obj/item/clothing/suit/space/rig/nanite
	helm_type =  /obj/item/clothing/head/helmet/space/rig/nanite
	boot_type =  /obj/item/clothing/shoes/magboots/rig/nanite
	glove_type = /obj/item/clothing/gloves/rig/nanite
	cell_type =  /obj/item/cell/large/moebius/super

	var/charge_tick = 10
	var/recharge_time = 10

/obj/item/rig/nanite/opifex
	air_type = /obj/item/tank/nitrogen
	air_supply = /obj/item/tank/nitrogen

/obj/item/rig/nanite/New()
	..()
	Initialize()

/obj/item/rig/nanite/Process()
	..()
	charge_tick++
	if(charge_tick < recharge_time) return 0
		charge_tick = 0

	if(!cell || cell.charge >= cell.maxcharge)
		return FALSE // check if we actually need to recharge

	if(drain_apc(drain)) //Take power from the APC...
		cell.give(drain) //... to recharge the shot
	return TRUE

/obj/item/rig/nanite/proc/drain_apc(var/power_usage)
	var/area/A = get_area(src)
	if(!istype(A) || !A.powered(STATIC_EQUIP))
		return FALSE

	A.use_power(power_usage, STATIC_EQUIP)
	return TRUE

/obj/item/rig/nanite/emp_act(severity_class)
	if(severity_class >= 5)
		src.visible_message("The [src.name] has been destroyed by an EMP!")
		spawn(20) qdel(src)
	else
		..()

/obj/item/clothing/suit/space/rig/nanite
	name = "suit"

/obj/item/clothing/gloves/rig/nanite
	name = "gloves"

/obj/item/clothing/shoes/magboots/rig/nanite
	name = "shoes"

/obj/item/clothing/head/helmet/space/rig/nanite
	name = "hood"

/obj/item/rig/nanite/verb/remove_tank()
	set name = "Eject air tank"
	set desc = "Eject the hardsuit's air tank"
	set category = "Hardsuit"
	set src = usr.contents

	if(!air_supply)
		to_chat(usr, "There is not tank to remove.")
		return
	else
		usr.put_in_hands(air_supply)
		to_chat(usr, "You detach and remove \the [air_supply].")
		air_supply = null
		return

/obj/item/rig/nanite/verb/insert_tank()
	set name = "Insert air tank"
	set desc = "Insert an air canister in the rig"
	set category = "Hardsuit"
	set src = usr.contents

	var/obj/item/tank/I = usr.get_active_hand()
	if(istype(I, /obj/item/tank)) //Todo, some kind of check for suits without integrated air supplies.
		if(air_supply)
			to_chat(usr, "\The [src] already has a tank installed.")
			return

		if(!usr.unEquip(I))
			return
		air_supply = I
		I.forceMove(src)
		to_chat(usr, "You slot [I] into [src] and tighten the connecting valve.")
		return
