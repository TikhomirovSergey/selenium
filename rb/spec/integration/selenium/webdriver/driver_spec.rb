# encoding: utf-8
#
# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require_relative 'spec_helper'

module Selenium
  module WebDriver
    describe Driver do
      it 'should get the page title' do
        driver.navigate.to url_for('xhtmlTest.html')
        expect(driver.title).to eq('XHTML Test Page')
      end

      it 'should get the page source' do
        driver.navigate.to url_for('xhtmlTest.html')
        expect(driver.page_source).to match(%r{<title>XHTML Test Page</title>}i)
      end

      it 'should refresh the page' do
        driver.navigate.to url_for('javascriptPage.html')
        sleep 1 # javascript takes too long to load
        driver.find_element(id: 'updatediv').click
        expect(driver.find_element(id: 'dynamo').text).to eq('Fish and chips!')
        driver.navigate.refresh
        expect(driver.find_element(id: 'dynamo').text).to eq("What's for dinner?")
      end

      context 'screenshots' do
        it 'should save' do
          driver.navigate.to url_for('xhtmlTest.html')
          path = 'screenshot_tmp.png'

          begin
            driver.save_screenshot path
            expect(File.exist?(path)).to be true # sic
            expect(File.size(path)).to be > 0
          ensure
            File.delete(path) if File.exist?(path)
          end
        end

        it 'should return in the specified format' do
          driver.navigate.to url_for('xhtmlTest.html')

          ss = driver.screenshot_as(:png)
          expect(ss).to be_kind_of(String)
          expect(ss.size).to be > 0
        end

        it 'raises an error when given an unknown format' do
          expect { driver.screenshot_as(:jpeg) }.to raise_error(WebDriver::Error::UnsupportedOperationError)
        end
      end

      describe 'one element' do
        it 'should find by id' do
          driver.navigate.to url_for('xhtmlTest.html')
          element = driver.find_element(id: 'id1')
          expect(element).to be_kind_of(WebDriver::Element)
          expect(element.text).to eq('Foo')
        end

        it 'should find by field name' do
          driver.navigate.to url_for('formPage.html')
          expect(driver.find_element(name: 'x').attribute('value')).to eq('name')
        end

        it 'should find by class name' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.find_element(class: 'header').text).to eq('XHTML Might Be The Future')
        end

        it 'should find by link text' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.find_element(link: 'Foo').text).to eq('Foo')
        end

        it 'should find by xpath' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.find_element(xpath: '//h1').text).to eq('XHTML Might Be The Future')
        end

        it 'should find by css selector' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.find_element(css: 'div.content').attribute('class')).to eq('content')
        end

        it 'should find by tag name' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.find_element(tag_name: 'div').attribute('class')).to eq('navigation')
        end

        it 'should find child element' do
          driver.navigate.to url_for('nestedElements.html')

          element = driver.find_element(name: 'form2')
          child = element.find_element(name: 'selectomatic')

          expect(child.attribute('id')).to eq('2')
        end

        it 'should find child element by tag name' do
          driver.navigate.to url_for('nestedElements.html')

          element = driver.find_element(name: 'form2')
          child = element.find_element(tag_name: 'select')

          expect(child.attribute('id')).to eq('2')
        end

        it 'should raise on nonexistant element' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect { driver.find_element('nonexistant') }.to raise_error
        end

        it 'should find elements with a hash selector' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.find_element(class: 'header').text).to eq('XHTML Might Be The Future')
        end

        it 'should find elements with the shortcut syntax' do
          driver.navigate.to url_for('xhtmlTest.html')

          expect(driver[:id1]).to be_kind_of(WebDriver::Element)
          expect(driver[xpath: '//h1']).to be_kind_of(WebDriver::Element)
        end
      end

      describe 'many elements' do
        it 'should find by class name' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.find_elements(class: 'nameC').size).to eq(2)
        end

        it 'should find by css selector' do
          driver.navigate.to url_for('xhtmlTest.html')
          driver.find_elements(css: 'p')
        end

        it 'should find children by field name' do
          driver.navigate.to url_for('nestedElements.html')
          element = driver.find_element(name: 'form2')
          children = element.find_elements(name: 'selectomatic')
          expect(children.size).to eq(2)
        end
      end

      describe 'execute script' do
        it 'should return strings' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.execute_script('return document.title;')).to eq('XHTML Test Page')
        end

        it 'should return numbers' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.execute_script('return document.title.length;')).to eq(15)
        end

        it 'should return elements' do
          driver.navigate.to url_for('xhtmlTest.html')
          element = driver.execute_script("return document.getElementById('id1');")
          expect(element).to be_kind_of(WebDriver::Element)
          expect(element.text).to eq('Foo')
        end

        it 'should unwrap elements in deep objects' do
          driver.navigate.to url_for('xhtmlTest.html')
          result = driver.execute_script(<<-SCRIPT)
      var e1 = document.getElementById('id1');
      var body = document.body;

      return {
        elements: {'body' : body, other: [e1] }
      };
          SCRIPT

          expect(result).to be_kind_of(Hash)
          expect(result['elements']['body']).to be_kind_of(WebDriver::Element)
          expect(result['elements']['other'].first).to be_kind_of(WebDriver::Element)
        end

        it 'should return booleans' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.execute_script('return true;')).to eq(true)
        end

        it 'should raise if the script is bad' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect { driver.execute_script('return squiggle();') }.to raise_error
        end

        it 'should return arrays' do
          driver.navigate.to url_for('xhtmlTest.html')
          expect(driver.execute_script('return ["zero", "one", "two"];')).to eq(%w[zero one two])
        end

        it 'should be able to call functions on the page' do
          driver.navigate.to url_for('javascriptPage.html')
          driver.execute_script("displayMessage('I like cheese');")
          expect(driver.find_element(id: 'result').text.strip).to eq('I like cheese')
        end

        it 'should be able to pass string arguments' do
          driver.navigate.to url_for('javascriptPage.html')
          expect(driver.execute_script("return arguments[0] == 'fish' ? 'fish' : 'not fish';", 'fish')).to eq('fish')
        end

        it 'should be able to pass boolean arguments' do
          driver.navigate.to url_for('javascriptPage.html')
          expect(driver.execute_script('return arguments[0] == true;', true)).to eq(true)
        end

        it 'should be able to pass numeric arguments' do
          driver.navigate.to url_for('javascriptPage.html')
          expect(driver.execute_script('return arguments[0] == 1 ? 1 : 0;', 1)).to eq(1)
        end

        it 'should be able to pass null arguments' do
          driver.navigate.to url_for('javascriptPage.html')
          expect(driver.execute_script('return arguments[0];', nil)).to eq(nil)
        end

        it 'should be able to pass array arguments' do
          driver.navigate.to url_for('javascriptPage.html')
          expect(driver.execute_script('return arguments[0];', [1, '2', 3])).to eq([1, '2', 3])
        end

        it 'should be able to pass element arguments' do
          driver.navigate.to url_for('javascriptPage.html')
          button = driver.find_element(id: 'plainButton')
          js = "arguments[0]['flibble'] = arguments[0].getAttribute('id'); return arguments[0]['flibble'];"
          expect(driver.execute_script(js, button))
            .to eq('plainButton')
        end

        it 'should be able to pass in multiple arguments' do
          driver.navigate.to url_for('javascriptPage.html')
          expect(driver.execute_script('return arguments[0] + arguments[1];', 'one', 'two')).to eq('onetwo')
        end
      end

      not_compliant_on browser: :phantomjs do
        describe 'execute async script' do
          before do
            driver.manage.timeouts.script_timeout = 0
            driver.navigate.to url_for('ajaxy_page.html')
          end

          it 'should be able to return arrays of primitives from async scripts' do
            result = driver.execute_async_script "arguments[arguments.length - 1]([null, 123, 'abc', true, false]);"
            expect(result).to eq([nil, 123, 'abc', true, false])
          end

          it 'should be able to pass multiple arguments to async scripts' do
            result = driver.execute_async_script 'arguments[arguments.length - 1](arguments[0] + arguments[1]);', 1, 2
            expect(result).to eq(3)
          end

          # Edge BUG - https://connect.microsoft.com/IE/feedback/details/1849991/
          not_compliant_on browser: :edge do
            it 'times out if the callback is not invoked' do
              expect do
                # Script is expected to be async and explicitly callback, so this should timeout.
                driver.execute_async_script 'return 1 + 2;'
              end.to raise_error(Selenium::WebDriver::Error::ScriptTimeoutError)
            end
          end
        end
      end
    end
  end # WebDriver
end # Selenium
