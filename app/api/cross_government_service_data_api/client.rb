class CrossGovernmentServiceDataAPI::Client

  def metrics_by_department
    response = connection.get '/v1/data/departments'
    data = response.body
    data.map do |response|
      CrossGovernmentServiceDataAPI::Metrics.build(response)
    end
  end

  def services_metrics_by_department(department_id)
    department_id = URI.escape(department_id)
    response = connection.get "/v1/data/departments/#{department_id}/services"
    data = response.body
    data.map do |response|
      CrossGovernmentServiceDataAPI::Metrics.build(response)
    end
  end

  def government
    response = connection.get "/v1/data/government"
    CrossGovernmentServiceDataAPI::Government.build(response.body)
  end

  def department(id)
    id = URI.escape(id)
    response = connection.get "/v1/data/departments/#{id}"

    CrossGovernmentServiceDataAPI::Department.build(response.body['department'])
  end

  def service(id)
    id = URI.escape(id)
    response = connection.get "/v1/data/services/#{id}"

    department = CrossGovernmentServiceDataAPI::Department.build(response.body['department'])

    CrossGovernmentServiceDataAPI::Service.build(response.body['service'], department: department)
  end

  private
  def connection
    @connection ||= Faraday.new(ENV.fetch('API_URL')) do |connection|
      connection.basic_auth ENV.fetch('API_USERNAME'), ENV.fetch('API_PASSWORD')

      connection.response :json
      connection.response :raise_error

      connection.use :instrumentation
      connection.use CrossGovernmentServiceDataAPI::Logger

      connection.adapter Faraday.default_adapter
    end
  end
end
