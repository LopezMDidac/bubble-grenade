
static func array_difference(elements, elements_to_diff):
	var diff = []
	for element in elements:
		if not elements_to_diff.has(element):
			diff.append(element)
	return diff

static func recursive_colliding_bodies(
		body: PhysicsBody2D,
		contacts: Array, 
		contact_criteria: FuncRef 
	) -> Array:
	var body_contacts = body.get_colliding_bodies()

	for body_contact in body_contacts:
		var is_contact = contact_criteria.call_func(body, body_contact)
		
		if not body_contact in contacts and is_contact:
			contacts.append(body_contact)
			var _contacts = recursive_colliding_bodies(
				body_contact,
				contacts,
				contact_criteria
			)
	
	return contacts
