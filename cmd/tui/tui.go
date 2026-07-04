// SPDX-FileContributor: FlameFlag <github@flameflag.dev>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

package tui

import (
	"github.com/asciimoo/hister/cmd/tui/handle"
	"github.com/asciimoo/hister/cmd/tui/model"
	"github.com/asciimoo/hister/cmd/tui/render"
	"github.com/asciimoo/hister/config"

	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
)

type app struct{ m *model.Model }

func (a *app) Init() tea.Cmd {
	return textinput.Blink
}

func (a *app) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	return a, handle.Update(a.m, msg)
}

func (a *app) View() string {
	return render.View(a.m)
}

func SearchTUI(cfg *config.Config) error {
	m := model.InitialModel(cfg)
	a := &app{m: m}
	p := tea.NewProgram(a, tea.WithAltScreen(), tea.WithMouseCellMotion())
	_, err := p.Run()
	m.Close()
	return err
}
