// SPDX-License-Identifier: AGPL-3.0-or-later

package client

import (
	"encoding/json"
	"io"
	"net/url"
	"strconv"

	"github.com/asciimoo/hister/server/indexer"
)

func (c *Client) Search(q *indexer.Query) (_ *indexer.Results, err error) {
	params := url.Values{}
	params.Set("q", q.Text)
	if q.Highlight != "" {
		params.Set("highlight", q.Highlight)
	}
	if q.Sort != "" {
		params.Set("sort", q.Sort)
	}
	if q.Limit > 0 {
		params.Set("limit", strconv.Itoa(q.Limit))
	}
	if q.DateFrom != 0 {
		params.Set("date_from", strconv.FormatInt(q.DateFrom, 10))
	}
	if q.DateTo != 0 {
		params.Set("date_to", strconv.FormatInt(q.DateTo, 10))
	}
	if q.PageKey != "" {
		params.Set("page_key", q.PageKey)
	}
	if q.SemanticEnabled {
		params.Set("semantic", "1")
		if q.SemanticThreshold != 0 {
			params.Set("semantic_threshold", strconv.FormatFloat(q.SemanticThreshold, 'f', -1, 64))
		}
	}
	req, err := c.newRequest("GET", "/search?"+params.Encode(), nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/json")
	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer closeBody(resp, &err)
	if err := checkStatus(resp); err != nil {
		return nil, err
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	var res *indexer.Results
	if err := json.Unmarshal(body, &res); err != nil {
		return nil, err
	}
	return res, nil
}
