// Licensed to the Software Freedom Conservancy (SFC) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The SFC licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package org.openqa.selenium.environment.webserver;

import com.google.common.base.Charsets;
import com.google.common.base.Strings;
import com.google.common.net.MediaType;

import java.io.IOException;
import java.io.OutputStream;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GeneratedJsTestServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    String symbol = Strings.nullToEmpty(req.getPathInfo()).replace("../", "").replace("/", "$");
    byte[] data =
        ("<!DOCTYPE html>\n"
         + "<html>\n"
         + "<head>\n"
         + "<meta http-equiv=\"X-UA-Compatible\" content=\"IE-Edge\">\n"
         + "<!-- File generated by " + getClass().getName() + " -->\n"
         + "<title>" + req.getPathInfo() + "</title>\n"
         + "<script src=\"/third_party/closure/goog/base.js\"></script>\n"
         + "<script src=\"/javascript/deps.js\"></script>\n"
         + "<script>\n"
         + "  (function() {\n"
         + "    var path = '../../.." + req.getPathInfo() + "';\n"
         + "    goog.addDependency(path, ['" + symbol + "'],\n"
         + "        goog.dependencies_.requires['../../.." + req.getPathInfo() + "'] || [],\n"
         + "        !!goog.dependencies_.pathIsModule[path]);\n"
         + "    goog.require('" + symbol + "');\n"
         + "  })()\n"
         + "</script></head><body></body></html>").getBytes(Charsets.UTF_8);

    resp.setStatus(HttpServletResponse.SC_OK);
    resp.setContentType(MediaType.HTML_UTF_8.toString());
    resp.setContentLength(data.length);

    OutputStream stream = resp.getOutputStream();
    stream.write(data);
    stream.flush();
    stream.close();
  }
}
