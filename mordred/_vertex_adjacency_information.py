import numpy as np

from ._base import Descriptor


class VertexAdjacencyInformation(Descriptor):
    r"""vertex adjacency information descriptor.

    .. math::
        {\rm VAdjMat} = 1 + \log_2(m)

    where :math:`m` is number of heavy-heavy bonds.

    :rtype: float
    """

    explicit_hydrogens = False
    require_connected = False

    def __str__(self):
        return 'VAdjMat'

    def calculate(self, mol):
        m = sum(
            1
            for b in mol.GetBonds()
            if b.GetBeginAtom().GetAtomicNum() != 1 and
            b.GetEndAtom().GetAtomicNum() != 1
        )

        if m == 0:
            return np.nan

        return 1 + np.log2(m)
