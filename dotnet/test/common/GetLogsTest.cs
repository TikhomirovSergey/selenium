﻿using System.Collections.Generic;
using NUnit.Framework;
using System.Collections.ObjectModel;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;

namespace OpenQA.Selenium
{
    [TestFixture]
    [IgnoreBrowser(Browser.IE, "IE driver does not support logs API")]
    [IgnoreBrowser(Browser.Edge, "Edge driver does not support logs API")]
    [IgnoreBrowser(Browser.PhantomJS, "PhantomJS driver does not support logs API")]
    public class GetLogsTest : DriverTestFixture
    {
        private IWebDriver localDriver;

        [TearDown]
        public void QuitDriver()
        {
            if (localDriver != null)
            {
                localDriver.Quit();
                localDriver = null;
            }
        }

        [Test]
        public void LogBufferShouldBeResetAfterEachGetLogCall()
        {
            if (TestUtilities.IsMarionette(driver))
            {
                Assert.Ignore("Marionette does not support logs API.");
            }

            ReadOnlyCollection<string> logTypes = driver.Manage().Logs.AvailableLogTypes;
            foreach (string logType in logTypes)
            {
                driver.Url = simpleTestPage;
                ReadOnlyCollection<LogEntry> firstEntries = driver.Manage().Logs.GetLog(logType);
                if (firstEntries.Count > 0)
                {
                    ReadOnlyCollection<LogEntry> secondEntries = driver.Manage().Logs.GetLog(logType);
                    Assert.IsFalse(HasOverlappingLogEntries(firstEntries, secondEntries), string.Format("There should be no overlapping log entries in consecutive get log calls for {0} logs", logType));
                }
            }
        }

        [Test]
        public void DifferentLogsShouldNotContainTheSameLogEntries()
        {
            if (TestUtilities.IsMarionette(driver))
            {
                Assert.Ignore("Marionette does not support logs API.");
            }

            driver.Url = simpleTestPage;
            Dictionary<string, ReadOnlyCollection<LogEntry>> logTypeToEntriesDictionary = new Dictionary<string, ReadOnlyCollection<LogEntry>>();
            ReadOnlyCollection<string> logTypes = driver.Manage().Logs.AvailableLogTypes;
            foreach (string logType in logTypes)
            {
                logTypeToEntriesDictionary.Add(logType, driver.Manage().Logs.GetLog(logType));
            }

            foreach (string firstLogType in logTypeToEntriesDictionary.Keys)
            {
                foreach (string secondLogType in logTypeToEntriesDictionary.Keys)
                {
                    if (firstLogType != secondLogType)
                    {
                        Assert.IsFalse(HasOverlappingLogEntries(logTypeToEntriesDictionary[firstLogType], logTypeToEntriesDictionary[secondLogType]), string.Format("Two different log types ({0}, {1}) should not contain the same log entries", firstLogType, secondLogType));
                    }
                }
            }
        }

        [Test]
        public void TurningOffLogShouldMeanNoLogMessages()
        {
            if (TestUtilities.IsMarionette(driver))
            {
                Assert.Ignore("Marionette does not support logs API.");
            }

            ReadOnlyCollection<string> logTypes = driver.Manage().Logs.AvailableLogTypes;
            foreach (string logType in logTypes)
            {
                CreateWebDriverWithLogging(logType, LogLevel.Off);
                ReadOnlyCollection<LogEntry> entries = localDriver.Manage().Logs.GetLog(logType);
                Assert.AreEqual(0, entries.Count, string.Format("There should be no log entries for log type {0} when logging is turned off.", logType));
                QuitDriver();
            }
        }

        private void CreateWebDriverWithLogging(string logType, LogLevel logLevel)
        {
            if (TestUtilities.IsFirefox(driver))
            {
                Dictionary<string, object> firefoxLogs = new Dictionary<string, object>();
                firefoxLogs[logType] = logLevel.ToString().ToUpperInvariant();
                DesiredCapabilities caps = DesiredCapabilities.Firefox();
                caps.SetCapability(CapabilityType.LoggingPreferences, firefoxLogs);
                localDriver = new FirefoxDriver(caps);
            }
            else if (TestUtilities.IsChrome(driver))
            {
                ChromeOptions options = new ChromeOptions();
                options.SetLoggingPreference(logType, logLevel);
                localDriver = new ChromeDriver(options);
            }

            localDriver.Url = simpleTestPage;
        }

        private bool HasOverlappingLogEntries(ReadOnlyCollection<LogEntry> firstLog, ReadOnlyCollection<LogEntry> secondLog)
        {
            foreach (LogEntry firstEntry in firstLog)
            {
                foreach (LogEntry secondEntry in secondLog)
                {
                    if (firstEntry.Level == secondEntry.Level && firstEntry.Message == secondEntry.Message && firstEntry.Timestamp == secondEntry.Timestamp)
                    {
                        return true;
                    }
                }
            }

            return false;
        }
    }
}
