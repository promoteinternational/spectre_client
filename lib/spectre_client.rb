require "spectre_client/version"
require "rest_client"
require "json"

module SpectreClient
  class Client
    attr_reader :run_id

    def initialize(project_name, suite_name, url_base, run_id = nil, commit = nil, init_from_commit = nil)
      @project_name = project_name
      @suite_name = suite_name
      @url_base = url_base
      @commit = commit
      @init_from_commit = init_from_commit
      @run_id = run_id || create_run['id']
    end

    def run_data
      @run_data || { 'run_id' => @run_id }
    end

    def create_run
      request = RestClient::Request.execute(
        method: :post,
        url: "#{@url_base}/runs",
        timeout: 300,
        payload: {
          project: @project_name,
          suite: @suite_name,
          commit: @commit,
          init_from_commit: @init_from_commit,
        }
      )
      @run_data = JSON.parse(request.to_str)
    end

    def submit_test(options = {})
      source_url =  options[:source_url] || ''
      fuzz_level =  options[:fuzz_level] || ''
      highlight_colour = options[:highlight_colour] || ''

      request = RestClient::Request.execute(
        method: :post,
        url: "#{@url_base}/tests",
        timeout: 120,
        multipart: true,
        payload: {
          test: {
            run_id: @run_id,
            name: options[:name],
            browser: options[:browser],
            size: options[:size],
            screenshot: options[:screenshot],
            source_url: source_url,
            fuzz_level: fuzz_level,
            highlight_colour: highlight_colour,
            crop_area: options[:crop_area]
          }
        }
      )
      JSON.parse(request.to_str, symbolize_names: true)
    end
  end
end
