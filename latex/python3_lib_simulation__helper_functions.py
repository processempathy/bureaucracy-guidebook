def show_all_people(list_of_people: list):
    """assessment of whether `list_of_people` is correct"""
    for person in list_of_people:
        print('id=',person.unique_id,
              '; skill matrix=',person.skill_specialization_dict)
    return

def get_aggregate_person_dict(list_of_people:list,
                              skill_set_for_people:list,
                              max_skill_level_per_person: int):
    """create data structure for visualization of the population"""
    # initialize data structure
    aggregate_person_dict = {}
    for specialization in skill_set_for_people:
        aggregate_person_dict[specialization] = [0 for _ in range(max_skill_level_per_person)]
    # populate the data structure
    for person_id, person in enumerate(list_of_people):
        for specialization, skilllevel in person.skill_specialization_dict.items():
            #print(person_id, specialization, skilllevel)
            if skilllevel>0:
                aggregate_person_dict[specialization][skilllevel-1] += 1
    return aggregate_person_dict

def check_population_for_capability(list_of_people: list,
                                    skill_set_for_people,
                                    max_skill_level_per_person):
    """Due to random initialization of skill-levels,
    some populations may be incapable of certain tasks"""
    max_skill_per_specialization = {}

    # initialize to -1
    for specialization in skill_set_for_people:
        max_skill_per_specialization[specialization] = -1

    for person in list_of_people:
        #print(person.skill_specialization_dict)
        for persons_specialization, persons_skilllevel in person.skill_specialization_dict.items():
            if persons_skilllevel>max_skill_per_specialization[persons_specialization]:
                max_skill_per_specialization[persons_specialization] = persons_skilllevel

    for specialization, skilllevel in max_skill_per_specialization.items():
        if skilllevel<max_skill_level_per_person:
            print("WARNING: population lacks max skill-level for",specialization)
            print("As a consquence, some tasks cannot be completed by this population")
    return

# use defaults to avoid having to specify variables each time
def new_task(task_id:int,
             skill_set_for_tasks: list,
             max_skill_level_per_task: int,
             max_task_duration_in_ticks: int,
             tasks_dict: dict) -> dict:
    """create a task and modify the dict that tracks all tasks"""
    duration = random.randint(1,max_task_duration_in_ticks)
    tasks_dict[task_id] = {'task ID': task_id,
                           'specialization': random.choice(skill_set_for_tasks),
                           'skill level': random.randint(1,max_skill_level_per_task),
                           'duration': duration,
                           'remaining': duration}
    return tasks_dict

def current_status_of_people(list_of_people: list):
    """what is each person doing?"""
    for person in list_of_people:
        print('person id',person.unique_id,
                  'has status',person.status,
                  'with task=',person.assigned_task,
                  'and has',len(person.backlog_of_tasks),
                  'tasks in backlog')
    return

def cumulative_task_backlog_size(list_of_people):
    """value needed to create visualization of backlog versus time"""
    backlog_count = 0
    for person in list_of_people:
        backlog_count += len(person.backlog_of_tasks)
    return backlog_count

def pick_a_random_person(person_index: int,
                         contacts: list,
                         list_of_people: list):
    """find someone who is not myself and is not someone I already know"""
    try:
        len(contacts)
    except TypeError: # contacts is None
        contacts=[]
    attempts = 0
    list_of_person_IDs = [person.unique_id for person in list_of_people]
    while (attempts<100):
        attempts+=1
        another_person = random.choice(list_of_person_IDs)
        if ((another_person not in contacts) and
            (another_person != person_index)):
            return another_person
    #print("failed to find another person who is not a contact")
    return person_index