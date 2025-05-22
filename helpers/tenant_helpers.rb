module TenantHelpers
  def tenant
    tenant = ENV['TENANT']
    raise "Set the TENANT environment variable" if tenant.nil?
    return tenant
  end

  def tenant_data
    data[tenant]
  end

  def tenant_data_file(filename)
    File.join(root, 'data', tenant, filename)
  end
end

module Middleman
  module MetaTags
    module Helpers
      def site_data
        (tenant_data.site || {}).with_indifferent_access
      end
    end
  end
end