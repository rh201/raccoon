//* This file is part of the RACCOON application
//* being developed at Dolbow lab at Duke University
//* http://dolbow.pratt.duke.edu

#pragma once

#include "ADComputeStressBase.h"

class ADDegradedElasticStressBase : public ADComputeStressBase
{
public:
  static InputParameters validParams();

  ADDegradedElasticStressBase(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;
  virtual void computeQpStress() override {}

  /// enforce traction-free boundary condition
  virtual void computeQpTractionFreeStress();

  ///{@
  /// Macaulay bracket operator
  virtual ADReal Macaulay(ADReal x);
  virtual std::vector<ADReal> Macaulay(std::vector<ADReal> x);
  ///@}

  /// Elasticity tensor material property
  const ADMaterialProperty<RankFourTensor> & _elasticity_tensor;

  /// damage value
  const ADVariableValue & _d;

  /// damage gradient
  const ADVariableGradient & _grad_d;

  /// critical damage value for enforcing the traction-free boundary condition
  const Real _d_crit;

  /// degradation name
  const MaterialPropertyName _g_name;

  /// degradation
  const ADMaterialProperty<Real> & _g;

  /// elastic energy name
  const MaterialPropertyName _E_el_name;

  /// positive elastic driving energy
  ADMaterialProperty<Real> & _E_el_active;
};
