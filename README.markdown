## Quickstart

  ```ruby
  # Gemfile:
  gem 'rails-ioc'

  # config/dependencies/development.rb:
  RailsIOC::Dependencies.define do     
    prototype :card_validator,  CreditCardValidator, "Visa", "Mastercard"
    prototype :payment_gateway, DummyPaymentGateway, ref(:card_validator)
  
    controller PaymentsController, {
      payment_gateway: ref(:payment_gateway),
    }
  end   

  # app/controllers/payments_controller.rb:
  class PaymentsController < ApplicationController
    def accept_payment
      @payment_gateway.process(params[:credit_card])
    end
  end

  # spec/controllers/payments_controller_spec.rb
  it "processes a succesful payment" do
	controller_dependencies(payment_gateway: mock(PaymentGateway))
    controller.payment_gateway.should_receive(:process).with("4111").and_return(true)
	post :accept_payment, credit_card: "4111"
  end
  ```

## Background

Inversion of control via dependency injection is widely used in large software systems and is generally accepted to be a "Good Thing". If the terms are unfamiliar these are good places to start reading: 

- http://en.wikipedia.org/wiki/Inversion_of_control
- http://martinfowler.com/articles/injection.html

The practice as described in the articles above is not particularly common in Ruby applications. Jamis Buck, author of the erstwhile DI framework [Copland](http://copland.rubyforge.org) makes a [compelling argument](http://weblog.jamisbuck.org/2008/11/9/legos-play-doh-and-programming) against it. If you have to ask the question "Will I need IOC for my next Rails app", the answer is almost certainly "No". The core components of a standard Rails app usually interact politely and can generally be easily tested.

Still, having run into several Rails projects which dealt with dependencies beyond an ActiveRecord database connection (payment gateways, email services, version control systems, image processing services and more) I realised that I was reminiscing fondly about Java and .NET's various containers for two reasons:

1. **I really despise mocking calls to MyService#new to force a controller to use a stub implementation in a unit test.**
2. **There is no clean way to switch dependencies out on a per-environment basis (to use the testable version of a payment gateway in the staging environment, for example).**

RailsIOC attempts to make these problems less painful for applications with complex interactions with external services by providing a lightweight way to define dependencies and inject them into ActionController. The patterns will be familiar to anyone who has used [Spring](http://www.springsource.org/documentation) or [Unity](http://msdn.microsoft.com/en-us/library/dd203319.aspx). Dependencies are defined in pure Ruby using a simple internal DSL. Where possible, RailsIOC enforces constructor injection. The exception to this rule is the creation of controllers, where it avoids interfering with Rails' own instantiation and injects dependencies as @local_variables.

## Cleaner Testing
### Before
    
  ```ruby
  # Controller:
  @gateway = Gateway.new(ServiceA.new, ServiceB.new)
  @gateway.do_something!
  
  # RSpec:
  @svc_a = mock(ServiceA)
  @svc_b = mock(ServiceB)
  ServiceA.stub(:new).and_return(@svc_a)
  ServiceB.stub(:new).and_return(@svc_b)
  @gateway = mock(Gateway)
  @gateway.should_receive(:do_something!).and_return(12345)
  Gateway.stub(:new).with(@svc_a, @svc_b).and_return(@gateway)
  ```

### After

  ```ruby
  # Controller:
  @gateway.do_something!
  
  # RSpec:
  controller_dependencies(gateway: mock(Gateway))
  controller.gateway.should_receive(:do_something!).and_return(12345)
  ```

## Customise and Override Dependencies Per-Environment
### Before
    
  ```ruby
  # app/controllers/payments_controller.rb:
  class PaymentsController < ApplicationController
    def accept_payment
      if Rails.env.development? || Rails.env.test?
        @credit_card_validator = BogusCardValidator.new
      else
        @credit_card_validator = RealCardValidator.new
      end
      if Rails.env.production? 
        @gateway = RealPaymentGateway.new
      elsif Rails.env.staging? 
        @gateway = RealPaymentGateway.new(use_testing_url: true)
      else
        @gateway = BogusPaymentGateway.new
      end
      card = @credit_card_validator.validate(params[:card])
      @gateway.process(card)
    end
  end
  ```

### After

  ```ruby
  # app/controllers/payments_controller:
  class PaymentsController < ApplicationController
    def accept_payment    
      card = @credit_card_validator.validate(params[:card])
      @gateway.process(card)
    end
  end
    
  # config/dependencies/production.rb:
  RailsIOC::Dependencies.define do
    prototype :payment_gateway,       RealPaymentGateway
    prototype :credit_card_validator, RealCardValidator
    
    controller PaymentsController, {
      gateway:               ref(:payment_gateway)
      credit_card_validator: ref(:credit_card_validator)
    }
  end

  # config/dependencies/staging.rb:
  RailsIOC::Dependencies.define do
    inherit_environment(:production)
    
    controller PaymentsController, {
      gateway: prototype(RealPaymentGateway, use_testing_url: true)
    }
  end

  # config/dependencies/development.rb:
  RailsIOC::Dependencies.define do
    inherit_environment(:production)
  
    controller PaymentsController, {
      gateway:               singleton(BogusPaymentGateway),
      credit_card_validator: singleton(BogusCardValidator)
    }
  end
  ```