/mob/living/carbon/superior_animal/nanobot/Life()
	. = ..()

	// What it does if it can repair itself
	if(repair_rate)
		heal_overall_damage(repair_rate, repair_rate)

	// What it does if it is supposed to act as a medbot.
	if(medbot)
		if(patient)
			if(Adjacent(patient))
				if(!currently_healing)
					UnarmedAttack(patient)
				walk_to(src, 0) // Stop walking
			else
				walk_to(src, patient, 1, move_to_delay)
		else
			for(friends in view(7)) // Time to find a patient!
				if(valid_healing_target(friends))
					patient = friends
					break
