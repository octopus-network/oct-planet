package keeper_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	testkeeper "oct-pallet/testutil/keeper"
	"oct-pallet/x/octpallet/types"
)

func TestGetParams(t *testing.T) {
	k, ctx := testkeeper.OctpalletKeeper(t)
	params := types.DefaultParams()

	k.SetParams(ctx, params)

	require.EqualValues(t, params, k.GetParams(ctx))
}
