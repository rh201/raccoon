#include "LinearLocalDissipation.h"

registerADMooseObject("raccoonApp", LinearLocalDissipation);

defineADValidParams(LinearLocalDissipation,
                    ADMaterial,
                    params.addRequiredCoupledVar("d", "phase-field damage variable");
                    params.addParam<MaterialPropertyName>(
                        "local_dissipation_name",
                        "w",
                        "name of the material that holds the local dissipation"););

template <ComputeStage compute_stage>
LinearLocalDissipation<compute_stage>::LinearLocalDissipation(const InputParameters & parameters)
  : ADMaterial<compute_stage>(parameters),
    _d(adCoupledValue("d")),
    _w_name(adGetParam<MaterialPropertyName>("local_dissipation_name")),
    _w(adDeclareADProperty<Real>(_w_name)),
    _dw_dd(adDeclareADProperty<Real>(
        derivativePropertyNameFirst(_w_name, this->getVar("d", 0)->name())))
{
}

template <ComputeStage compute_stage>
void
LinearLocalDissipation<compute_stage>::computeQpProperties()
{
  ADReal d = _d[_qp];

  _w[_qp] = d;
  _dw_dd[_qp] = 1.0;
}