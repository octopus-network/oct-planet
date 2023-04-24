package oyster_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	keepertest "oyster/testutil/keeper"
	"oyster/testutil/nullify"
	"oyster/x/oyster"
	"oyster/x/oyster/types"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params: types.DefaultParams(),

		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.OysterKeeper(t)
	oyster.InitGenesis(ctx, *k, genesisState)
	got := oyster.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	// this line is used by starport scaffolding # genesis/test/assert
}
