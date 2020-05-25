from aiida import orm, plugins, engine

builder = plugins.CalculationFactory("quantumespresso.pw").get_builder()

builder.code = orm.Code.get(label="qe-direct")
builder.structure = orm.load_node("5eb94d2d-2f58-4769-9f74-80c223791077")
builder.kpoints = orm.load_node("a63f51e4-4a86-4271-bb30-ad69c1e1a7e2")
builder.parameters = orm.load_node("ea01fb5e-9098-481c-b46e-57cfa60a77cc")
upf_family = orm.Group.get(label="SSSP/1.1/PBE/efficiency", type_string="sssp.family")
builder.pseudos = upf_family.get_pseudos(builder.structure)
builder.metadata.options.withmpi = True
builder.metadata.options.resources = {"num_machines": 1, "tot_num_mpiprocs": 2}
builder.metadata.options.max_wallclock_seconds = 1800

calc = engine.submit(builder)
print("pk=", calc.pk)
