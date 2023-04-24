package keeper

import (
	"oyster/x/oyster/types"
)

var _ types.QueryServer = Keeper{}
