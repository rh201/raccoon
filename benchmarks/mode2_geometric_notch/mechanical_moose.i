Gc = 1e-3
l = 0.015

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = 'fracture_moose.i'
    app_type = raccoonApp
    execute_on = 'TIMESTEP_BEGIN'
    cli_args = 'Gc=${Gc};l=${l}'
  []
[]

[Transfers]
  [send_disp_x]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = to_multiapp
    source_variable = 'disp_x'
    variable = 'disp_x'
  []
  [send_disp_y]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = to_multiapp
    source_variable = 'disp_y'
    variable = 'disp_y'
  []
  [get_d]
    type = MultiAppCopyTransfer
    multi_app = fracture
    direction = from_multiapp
    source_variable = 'd'
    variable = 'd'
  []
[]

[Mesh]
  type = FileMesh
  file = 'gold/geo0.msh'
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Modules]
  [TensorMechanics]
    [Master]
      [mech]
        add_variables = true
        strain = SMALL
        save_in = 'resid_x resid_y'
      []
    []
  []
[]

[AuxVariables]
  [resid_x]
  []
  [resid_y]
  []
  [d]
  []
[]

[BCs]
  [xdisp]
    type = FunctionDirichletBC
    variable = 'disp_x'
    boundary = 'top'
    function = 't'
  []
  [yfix]
    type = DirichletBC
    variable = 'disp_y'
    # boundary = 'top bottom left right'
    boundary = 'top bottom'
    value = 0
  []
  [xfix]
    type = DirichletBC
    variable = 'disp_x'
    boundary = 'bottom'
    value = 0
  []
[]

[Materials]
  [pfbulkmat]
    type = GenericConstantMaterial
    prop_names = 'gc_prop l visco'
    prop_values = '${Gc} ${l} 1e-3'
  []
  [define_mobility]
    type = ParsedMaterial
    material_property_names = 'gc_prop visco'
    f_name = L
    function = '1.0/(gc_prop * visco)'
  []
  [define_kappa]
    type = ParsedMaterial
    material_property_names = 'gc_prop l'
    f_name = kappa_op
    function = 'gc_prop * l'
  []
  [elasticity_tensor]
    type = ComputeElasticityTensor
    C_ijkl = '120.0 80.0'
    fill_method = symmetric_isotropic
  []
  [damage_stress]
    type = ComputeLinearElasticPFFractureStress
    c = d
    E_name = 'elastic_energy'
    D_name = 'degradation'
    F_name = 'local_fracture_energy'
    decomposition_type = strain_vol_dev
  []
  [degradation]
    type = DerivativeParsedMaterial
    f_name = degradation
    args = 'd'
    function = '(1.0-d)^2*(1.0 - eta) + eta'
    constant_names = 'eta'
    constant_expressions = '0.0'
    derivative_order = 2
  []
  [local_fracture_energy]
    type = DerivativeParsedMaterial
    f_name = local_fracture_energy
    args = 'd'
    material_property_names = 'gc_prop l'
    function = 'd^2 * gc_prop / 2 / l'
    derivative_order = 2
  []
  [fracture_driving_energy]
    type = DerivativeSumMaterial
    args = d
    sum_materials = 'elastic_energy local_fracture_energy'
    derivative_order = 2
    f_name = F
  []
[]

[Postprocessors]
  [Fx]
    type = NodalSum
    variable = resid_x
    boundary = 2
  []
  [Fy]
    type = NodalSum
    variable = resid_y
    boundary = 2
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'
  dt = 2e-6
  end_time = 2e-2

  nl_abs_tol = 1e-08
  nl_rel_tol = 1e-06

  automatic_scaling = true

  # picard_max_its = 100
  # picard_abs_tol = 1e-08
  # picard_rel_tol = 1e-06
[]

[Outputs]
  print_linear_residuals = false
  print_linear_converged_reason = false
  print_nonlinear_converged_reason = false
  [csv]
    type = CSV
    delimiter = ' '
    file_base = 'force_displacement_moose'
    time_column = false
  []
  [exodus]
    type = Exodus
    file_base = 'visualize_moose'
    interval = 50
  []
  [console]
    type = Console
    hide = 'Fx Fy'
  []
[]