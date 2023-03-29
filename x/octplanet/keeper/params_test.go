package keeper_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	testkeeper "oct-planet/testutil/keeper"
	"oct-planet/x/octplanet/types"
)

func TestGetParams(t *testing.T) {
	k, ctx := testkeeper.OctplanetKeeper(t)
	params := types.DefaultParams()

	k.SetParams(ctx, params)

	require.EqualValues(t, params, k.GetParams(ctx))
}
