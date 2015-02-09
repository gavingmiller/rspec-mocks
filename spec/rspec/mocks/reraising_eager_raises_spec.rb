require "spec_helper"

RSpec.describe "Reraising eager raises during the verify step" do
  it "does not reraise when a double receives a message that hasn't been allowed/expected" do
    expect {
      with_unfulfilled_double do |dbl|
        begin
          dbl.foo
        rescue RSpec::Mocks::MockExpectationError
          RSpec::Mocks.verify
        end
      end
    }.not_to raise_error
  end

  it "reraises when a negative expectation receives a call" do
    with_unfulfilled_double do |dbl|
      expect {
        begin
          expect(dbl).not_to receive(:foo)
          dbl.foo
        rescue RSpec::Mocks::MockExpectationError
          RSpec::Mocks.verify
        end
      }.to fail_with(/expected: 0 times with any arguments/)
    end
  end

  it "reraises when an expectation with a count is violated" do
    with_unfulfilled_double do |dbl|
      expect {
        begin
          expect(dbl).to receive(:foo).exactly(2).times
          dbl.foo
          dbl.foo
          dbl.foo
        rescue RSpec::Mocks::MockExpectationError
          RSpec::Mocks.verify
        end
      }.to fail_with(/expected: 2 times with any arguments/)
    end
  end

  it "reraises when an expectation is called with the wrong arguments" do
    with_unfulfilled_double do |dbl|
      expect {
        begin
          expect(dbl).to receive(:foo).with(1,2,3)
          dbl.foo(1,2,4)
        rescue RSpec::Mocks::MockExpectationError
          RSpec::Mocks.verify
        end
      }.to fail_with(/expected: 1 time with arguments: \(1, 2, 3\)/)
    end
  end

  it "reraises when an expectation is called out of order" do
    with_unfulfilled_double do |dbl|
      expect {
        begin
          expect(dbl).to receive(:foo).ordered
          expect(dbl).to receive(:bar).ordered
          dbl.bar
        rescue RSpec::Mocks::MockExpectationError
          RSpec::Mocks.verify
        end
      }.to fail_with(/\.foo/)
    end
  end
end
