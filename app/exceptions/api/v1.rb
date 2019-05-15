# frozen_string_literal: true

module Api
  module V1
    module ErrorCodes
      VALIDATION_ERROR = '100'
      SAVE_FAILED = '121'
      BAD_REQUEST = '400'
      UNAUTHORIZED = '401'
      FORBIDDEN = '403'
      RECORD_NOT_FOUND = '404'
      UNSUPPORTED_MEDIA_TYPE = '415'
      UNPROCESSABLE_ENTITY = '422'
      INTERNAL_SERVER_ERROR = '500'
    end

    class BaseError
      attr_accessor :title, :detail, :id, :href, :code, :source, :links, :status, :meta

      def initialize(options = {})
        @title          = options[:title]
        @detail         = options[:detail]
        @id             = options[:id]
        @code           = options[:code]
        @source         = options[:source]
        @status         = Rack::Utils::SYMBOL_TO_STATUS_CODE[options[:status]].to_s
        @meta           = options[:meta]
      end

      def to_hash
        hash = {}
        instance_variables.each do |var|
          hash[var.to_s.delete('@')] = instance_variable_get(var) unless instance_variable_get(var).nil?
        end
        hash
      end
    end

    class Error < RuntimeError
      attr_reader :error_object_overrides

      def initialize(error_object_overrides = {})
        @error_object_overrides = error_object_overrides
      end

      def create_error_object(error_defaults)
        Api::V1::BaseError.new(error_defaults.merge(error_object_overrides))
      end

      def errors
        # :nocov:
        raise NotImplementedError, 'Subclass of Error must implement errors method'
        # :nocov:
      end
    end

    class InternalServerError < Error
      attr_accessor :exception

      def initialize(exception, error_object_overrides = {})
        @exception = exception
        super(error_object_overrides)
      end

      def errors
        meta = {}
        meta[:exception] = exception.message
        meta[:backtrace] = exception.backtrace

        [create_error_object(code: Api::V1::ErrorCodes::INTERNAL_SERVER_ERROR,
                             status: :internal_server_error,
                             title: I18n.t('exceptions.internal_server_error.title',
                                           default: 'Internal Server Error'),
                             detail: I18n.t('exceptions.internal_server_error.detail',
                                            default: 'Internal Server Error'),
                             meta: meta)]
      end
    end

    class RecordNotFound < Error
      attr_accessor :id

      def initialize(id, error_object_overrides = {})
        @id = id
        super(error_object_overrides)
      end

      def errors
        [create_error_object(code: Api::V1::ErrorCodes::RECORD_NOT_FOUND,
                             status: :not_found,
                             title: I18n.translate('exceptions.record_not_found.title',
                                                   default: 'Record not found'),
                             detail: I18n.translate('exceptions.record_not_found.detail',
                                                    default: "The record with id: #{id} could not be found.",
                                                    id: id))]
      end
    end

    class BadRequest < Error
      def initialize(exception)
        @exception = exception
      end

      def errors
        [Api::V1::BaseError.new(code: Api::V1::ErrorCodes::BAD_REQUEST,
                                status: :bad_request,
                                title: I18n.translate('exceptions.bad_request.title',
                                                      default: 'Bad Request'),
                                detail: I18n.translate('exceptions.bad_request.detail',
                                                       default: @exception))]
      end
    end

    class ValidationErrors < Error
      attr_reader :error_messages, :error_metadata, :resource_relationships

      def initialize(resource, error_object_overrides = {})
        @error_messages = resource.errors.instance_variable_get('@messages')
        # @error_metadata = resource.errors
        super(error_object_overrides)
      end

      def errors
        error_messages.flat_map do |attr_key, messages|
          messages.map { |message| format_error(attr_key, message) }
        end
      end

      private

      def format_error(attr_key, message)
        create_error_object(code: Api::V1::ErrorCodes::UNPROCESSABLE_ENTITY,
                            status: :unprocessable_entity,
                            title: message,
                            detail: "#{attr_key} - #{message}",
                            meta: metadata_for(attr_key, message))
      end

      def metadata_for(attr_key, message)
        return if error_metadata.nil?

        error_metadata[attr_key] ? error_metadata[attr_key][message] : nil
      end
    end

    class SaveFailed < Error
      def errors
        [create_error_object(code: Api::V1::ErrorCodes::SAVE_FAILED,
                             status: :unprocessable_entity,
                             title: I18n.translate('exceptions.save_failed.title',
                                                   default: 'Save failed or was cancelled'),
                             detail: I18n.translate('exceptions.save_failed.detail',
                                                    default: 'Save failed or was cancelled'))]
      end
    end

    # Exception class used for Unprocessable Entity HTTP 422 responses
    class UnprocessableEntity < ValidationErrors
      attr_accessor :resource

      private

      def json_api_error(attr_key, message)
        create_error_object(code: Api::V1::ErrorCodes::UNPROCESSABLE_ENTITY,
                            status: :unprocessable_entity,
                            title: message,
                            detail: "#{attr_key} - #{message}",
                            source: { pointer: pointer(attr_key) },
                            meta: metadata_for(attr_key, message))
      end
    end

    # Exception class used for Unauthorized HTTP 401 responses
    class Unauthorized < Error
      def initialize(exception)
        @exception = exception
      end

      def errors
        [Api::V1::BaseError.new(code: Api::V1::ErrorCodes::UNAUTHORIZED,
                                status: :unauthorized,
                                title: I18n.translate('exceptions.unauthorized.title',
                                                      default: 'Not authorized'),
                                detail: I18n.translate('exceptions.unauthorized.detail',
                                                       default: @exception))]
      end
    end
  end
end
