// SPDX-FileContributor: FlameFlag <github@flameflag.dev>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

package network

import (
	"github.com/asciimoo/hister/client"
	"github.com/asciimoo/hister/cmd/tui/model"
	"github.com/asciimoo/hister/server/indexer"

	tea "github.com/charmbracelet/bubbletea"
)

func Search(c *client.Client, q model.SearchQuery) tea.Cmd {
	return func() tea.Msg {
		res, err := c.Search(&indexer.Query{
			Text:      q.Text,
			Highlight: q.Highlight,
			Limit:     q.Limit,
			Sort:      q.Sort,
		})
		if err != nil {
			return model.ErrMsg{Err: err}
		}
		if res == nil || (len(res.Documents) == 0 && len(res.History) == 0) {
			res = &indexer.Results{}
		}
		return model.ResultsMsg{Results: res}
	}
}
