package octplanet_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	keepertest "oct-planet/testutil/keeper"
	"oct-planet/testutil/nullify"
	"oct-planet/x/octplanet"
	"oct-planet/x/octplanet/types"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params: types.DefaultParams(),

		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.OctplanetKeeper(t)
	octplanet.InitGenesis(ctx, *k, genesisState)
	got := octplanet.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	// this line is used by starport scaffolding # genesis/test/assert
}
