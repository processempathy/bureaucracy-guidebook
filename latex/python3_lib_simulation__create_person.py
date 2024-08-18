class CreatePerson():
    """a person is a member of an organization 
       and has characteristics
    """
    def __init__(self, unique_id:int,
                 skill_set_for_people:list,
                 max_skill_level_per_person:int):
        self.unique_id = unique_id 
        self.backlog_of_tasks = []
        self.status = "idle"
        self.assigned_task = None
        self.contact_list = []
        self.skill_specialization_dict = {}
        self.work_journal_per_tick = {}
        for skill in skill_set_for_people:
            self.skill_specialization_dict[skill] = random.randint(
                    0,max_skill_level_per_person)
        return

    def add_person_to_contact_list(self, person_id: int, 
              social_circle_size: int)  -> None:
        """Intended to capture 
           https://en.wikipedia.org/wiki/Dunbar%27s_number"""
        self.contact_list.append(person_id)
        if len(self.contact_list)>social_circle_size:
            self.contact_list.pop(0)
        return