import random # don't import random because it overwrites the random seed set in the notebook?
import numpy
import pandas
import sys

"""
module for the simulation of work distribution in a flat organization
"""

random.seed(10)

class CreatePerson():
    """
    a person is a member of an organization
    and has characteristics
    """
    def __init__(self, 
                 unique_id:int, 
                 skill_set_for_people:list, 
                 max_skill_level_per_person:int):
        self.unique_id = unique_id # problem: this can be set by the user after initialization; see https://stackoverflow.com/a/48709694/1164295
        self.backlog_of_tasks = []
        self.status = "idle"
        self.assigned_task = None 
        self.contact_list = []
        self.skill_specialization_dict = {}
        self.work_journal_per_tick = {}
        for skill in skill_set_for_people:
            self.skill_specialization_dict[skill] = random.randint(0,max_skill_level_per_person)
        return

    def add_person_to_contact_list(self, person_id: int) -> None:
        """
        https://en.wikipedia.org/wiki/Dunbar%27s_number
        """
        self.contact_list.append(person_id)
        if len(self.contact_list)>social_circle_size:
            self.contact_list.pop(0)
        return

    
def show_all_people(list_of_people):
    for person in list_of_people:
        print('id=',person.unique_id, 
              '; skill matrix=',person.skill_specialization_dict)

def get_aggregate_person_dict(list_of_people:list,
                              skill_set_for_people:list,
                              max_skill_level_per_person: int):
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
        
def check_population_for_capability(list_of_people,
                                    skill_set_for_people,
                                    max_skill_level_per_person):
    """
    Due to random initialization of skill-levels,
    some populations may be incapable of certain tasks
    """
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
    """
    create a task and modify the dict that tracks all tasks
    """
    duration = random.randint(1,max_task_duration_in_ticks)
    tasks_dict[task_id] = {'task ID': task_id,
                           'specialization': random.choice(skill_set_for_tasks),
                           'skill level': random.randint(1,max_skill_level_per_task),
                           'duration': duration,
                           'remaining': duration}
    return tasks_dict

def current_status_of_people(list_of_people: list):
    """
    what is each person doing?
    """
    for person in list_of_people:
        #if person.assigned_task:
        #    if len(person.assigned_task)>0:
        #        task=person.assigned_task
        #    else:
        #        task = None
        #else:
         #   task = None
        print('person id',person.unique_id, 
                  'has status',person.status,
                  'with task=',person.assigned_task,
                  'and has',len(person.backlog_of_tasks),
                  'tasks in backlog')
    return

def cumulative_task_backlog_size(list_of_people):
    backlog_count = 0
    for person in list_of_people:
        backlog_count += len(person.backlog_of_tasks)
    return backlog_count


def pick_a_random_person(person_index: int, 
                         contacts: list, 
                         list_of_people: list):
    """
    find someone who is not myself and is not someone I already know
    """
    attempts = 0
    try:
        len(contacts)
    except TypeError: # contacts is None
        contacts=[]
    while (attempts<100):
        another_person = random.choice(range(len(list_of_people)))
        if ((another_person not in contacts) and 
            (another_person != person_index)):
            return another_person
    print("failed to find another person who is not a contact")
    return None


def simulate(skill_set_for_tasks:list,
             max_skill_level_per_task: int,
             max_ticks_to_simulate: int,
             max_task_duration_in_ticks:int,
             list_of_people: list,
             tasks_dict: dict,
             show_narrative:bool,
             work_journal:bool):
    """
    """
    tick=-1
    while ((tick<max_ticks_to_simulate)):
        tick=tick+1
        if show_narrative: print('\n===== tick',tick,'=====')
        if show_narrative: print("   ===== status at the leading edge of this tick: =====")
        if show_narrative: current_status_of_people(list_of_people)
        if show_narrative: print("   ===== updates happening in this tick: =====")
        # each person looks in their backlog for work
        for person_index in range(len(list_of_people)):
            skill_dict = list_of_people[person_index].skill_specialization_dict
            if show_narrative: print("person",person_index,'has skills',skill_dict)

            # initialize the work journal        
            if work_journal: list_of_people[person_index].work_journal_per_tick[tick] = {'number of tasks in backlog': 
                                                                        len(list_of_people[person_index].backlog_of_tasks)}
            if show_narrative: print("   person",person_index,"has backlog length",len(list_of_people[person_index].backlog_of_tasks))

            # make sure the idle people get assigned work
            if list_of_people[person_index].status=="idle":
                if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status was'] = "idle"
                assert(list_of_people[person_index].assigned_task is None)
                if len(list_of_people[person_index].backlog_of_tasks)>0:
                    # new tasks get appended, so the oldest task is at position 0
                    list_of_people[person_index].assigned_task = list_of_people[person_index].backlog_of_tasks.pop(0)
                    if show_narrative: print("   person",person_index,"got task from their backlog")
                    if show_narrative: print("      task is",list_of_people[person_index].assigned_task)
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['task from'] = 'my own backlog'
                else: # pop from empty list
                    task_id = max(tasks_dict.keys())+1
                    tasks_dict = new_task(task_id,
                                          skill_set_for_tasks,
                                          max_skill_level_per_task,
                                          max_task_duration_in_ticks,
                                          tasks_dict)                    
                    list_of_people[person_index].assigned_task = tasks_dict[task_id]
                    if show_narrative: print("   person",person_index,"had no tasks in backlog; got new task from infinite queue")
                    if show_narrative: print("      task consists of",list_of_people[person_index].assigned_task)
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['task from'] = 'infinite backlog'

            # at this point, regardless of status, the person has a task
            if not list_of_people[person_index].assigned_task:
                raise Exception("person",person_index,"should have a task")
                
            my_task = list_of_people[person_index].assigned_task
            if show_narrative: print("   person",person_index,"has an assigned task",my_task)
            if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['task'] = my_task
            
            # can the person do the task, or do they need to coordinate?
            if (my_task['skill level'] <= skill_dict[my_task['specialization']]): # person can do task
                if show_narrative: print("   person",person_index,"can do the task!")
                list_of_people[person_index].status="working"
                if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status was'] = "idle"
                if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "working"
            else: # person doesn't have sufficient skill for task; person needs to find someone else
                if show_narrative: print("   person",person_index,"does not have sufficient skill")
                list_of_people[person_index].status="coordinating"
                if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status was'] = "idle"
                if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "coordinating"

            # no person is idle
            assert((list_of_people[person_index].status=="working") or 
                   (list_of_people[person_index].status=="coordinating"))

            if list_of_people[person_index].status=="working":
                speedup = skill_dict[my_task['specialization']]/my_task['skill level']
                if show_narrative: print("   speedup for person",person_index,"is", speedup)
                list_of_people[person_index].assigned_task['remaining'] = my_task['remaining'] - speedup # "doing the work"
                if (list_of_people[person_index].assigned_task['remaining']<=0): # task was completed
                    if show_narrative: print("   task completed!")
                    list_of_people[person_index].assigned_task = None
                    list_of_people[person_index].status="idle"
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = "task completed"
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "idle"
                else: # update the task to reflect there being less work remaining because the person did some work
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = "worked but task remains"
                    if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "working"
                    pass
                    
            if list_of_people[person_index].status=="coordinating":
                contacts = list_of_people[person_index].contact_list
                if show_narrative: print("   person",person_index,"contacts=",contacts)
                if len(contacts)>0: # I know people!
                    if show_narrative: print("   person",person_index,"looks in contact list")
                    for contact_id in contacts: # do the people I know have the skills to do this task?
                        contacts_skill_dict = list_of_people[contact_id].skill_specialization_dict
                        if (my_task['skill level'] <= contacts_skill_dict[my_task['specialization']]): # contact can do task
                            list_of_people[contact_id].backlog_of_tasks.append(list_of_people[person_index].assigned_task)
                            list_of_people[person_index].assigned_task = None
                            list_of_people[person_index].status = "idle" # next tick will get new task from my own backlog or infinite backlog
                            if show_narrative: print("   person",person_index,"gave task to person",contact_id,"from contact list")
                            if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = "gave task to person "+str(contact_id)+" from contact list"
                            list_of_people[person_index].add_person_to_contact_list(contact_id)
                            if show_narrative: print("   person",person_index,"added",contact_id,"to list of contacts")
                            if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "idle"
                # after looking through contacts, if the status is still "coordinating", 
                # then person didn't have a contact who could do the work
                if list_of_people[person_index].status=="coordinating": 
                    another_person_id = pick_a_random_person(person_index, contacts, list_of_people)
                    another_person_skill_dict = list_of_people[another_person_id].skill_specialization_dict
                    if (my_task['skill level'] <= another_person_skill_dict[my_task['specialization']]): # another_person can do task
                        list_of_people[another_person_id].backlog_of_tasks.append(my_task)
                        list_of_people[person_index].assigned_task = None
                        list_of_people[person_index].status = "idle"
                        if show_narrative: print("   person",person_index,"gave task to person",another_person_id,"from random search")
                        if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = "gave task to person "+str(another_person_id)+" from random search"
                        if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "idle"
                    else:
                        if show_narrative: print("   person",person_index,"not able give to",another_person_id,"from random search")
                        if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['outcome'] = "not able to give to person "+str(another_person_id)+" from random search"
                        if work_journal: list_of_people[person_index].work_journal_per_tick[tick]['status is now'] = "coordinating"

    return list_of_people, tasks_dict


# EOF