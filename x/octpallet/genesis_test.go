package octpallet_test

import (
	"testing"

	"github.com/stretchr/testify/require"
	keepertest "oct-pallet/testutil/keeper"
	"oct-pallet/testutil/nullify"
	"oct-pallet/x/octpallet"
	"oct-pallet/x/octpallet/types"
)

func TestGenesis(t *testing.T) {
	genesisState := types.GenesisState{
		Params: types.DefaultParams(),

		// this line is used by starport scaffolding # genesis/test/state
	}

	k, ctx := keepertest.OctpalletKeeper(t)
	octpallet.InitGenesis(ctx, *k, genesisState)
	got := octpallet.ExportGenesis(ctx, *k)
	require.NotNil(t, got)

	nullify.Fill(&genesisState)
	nullify.Fill(got)

	// this line is used by starport scaffolding # genesis/test/assert
}
