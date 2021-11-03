using iIDReaderLibrary.Utils;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows;
using TELIDLibrary;
using TELIDLibrary.Utils;

namespace SampleBlocking_CSharp
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private readonly BackgroundWorker m_Worker = new BackgroundWorker();
        private bool m_ReaderFound = false;

        TelidControl m_TelidControl = null;
        TelidStateInformation m_LastReadState = null;

        public MainWindow()
        {
            InitializeComponent();

            SetUiEnabled(false, 0);
            m_Worker.WorkerReportsProgress = true;
            m_Worker.WorkerSupportsCancellation = true;
            m_Worker.DoWork += Worker_DoWork;

            textBlockInitialize_DriverVersion.Text = TELIDLibrary.Version.LibraryVersion;
            textBlock_ReaderInfo.Text = "Library version: " + textBlockInitialize_DriverVersion.Text + "  - Waiting for Initialize";
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            if (m_TelidControl != null)
                m_TelidControl.Dispose();
        }

        private void SetUiEnabled(bool _enabled, int _readerID)
        {
            Dispatcher.Invoke(() =>
            {
                tabItem_T300.IsEnabled = _enabled;

                if (_enabled)
                {
                    if (_readerID > 0)
                        textBlock_ReaderInfo.Text = "ReaderID: " + _readerID;
                }
                else
                {
                    tabControl.SelectedIndex = 0;
                    textBlock_ReaderInfo.Text = "Communication lost/not possible  - Waiting for Initialize";
                    textBlock_Status.Text = "";
                }
            });
        }

        #region Initialize
        private void ButtonInitialize_Click(object sender, RoutedEventArgs e)
        {
            if (radioButtonInitialize_PortUsb.IsChecked.Value)
            {
                //For USB communication, no parameters needed
                m_TelidControl = new TelidControl();
            }
            else
            {
                //For serial/bluetooth, get needed parameters
                byte portType = 0;
                if (radioButtonInitialize_PortBt.IsChecked.Value)
                    portType = 2;
                var readerPortSetings = InterfaceCommunicationSettings.GetForSerialDevice(portType, textBoxInitialize_PortName.Text);
                m_TelidControl = new TelidControl(readerPortSetings);
            }
            //On this event the read-progress is notified
            m_TelidControl.ReadLogProtocol_ProgressPercentageUpdated += TelidControl_ReadLogProtocol_ProgressPercentageUpdated;

            //Initialize
            if (m_TelidControl.Initialize())
            {
                //Initialize worked --> Enable UI & enable BackgroundWorker to check Reader-ID
                textBlock_ReaderInfo.Text = "Initialize Result: True";
                if (m_Worker.IsBusy != true)
                {
                    // Start the asynchronous operation.
                    m_Worker.RunWorkerAsync();
                }
            }
            else
            {
                //Initialize didn't work --> disable UI
                textBlock_ReaderInfo.Text = "Initialize Result: False";
                SetUiEnabled(false, 0);
            }
        }

        private void ButtonTerminate_Click(object sender, RoutedEventArgs e)
        {
            //Stop background worker
            m_Worker.CancelAsync();

            if (m_TelidControl != null)
            {
                m_TelidControl.Terminate();
            }
            m_ReaderFound = false;
            SetUiEnabled(false, 0);
        }

        private void Worker_DoWork(object sender, DoWorkEventArgs e)
        {
            BackgroundWorker worker = sender as BackgroundWorker;
            int readerCheckFailCount = 0;
            //Check readerID in 5 seconds interval. Hint: This interval is not fixed! It is recomended to check the communication with the reader when no other operation is executed.
            TimeSpan readerCheckSpan = TimeSpan.FromSeconds(5);
            //Initialize lastChecked in the past --> when Worker started it should check for the ReaderID first of all
            DateTime lastCheckedOk = DateTime.UtcNow.AddMinutes(-1);

            //While port initialized:
            //  Check reader communication is still possible in 5 seconds interval
            while (m_TelidControl.IsInitialized)
            {
                if (worker.CancellationPending == true)
                {
                    //Exit loop if Background worker is cancelled
                    e.Cancel = true;
                    break;
                }
                else
                {
                    if ((DateTime.UtcNow - lastCheckedOk) < readerCheckSpan)
                    {
                        //Next check time still not reached --> just do nothing
                        continue;
                    }
                    else
                    {
                        //Next check time reached --> check ReaderID
                        var readerID = m_TelidControl.ReaderID;
                        if (readerID != null)
                        {
                            //ReaderID check OK
                            readerCheckFailCount = 0;
                            lastCheckedOk = DateTime.UtcNow;
                            if (!m_ReaderFound)
                            {
                                //Not previously found --> Enable functions
                                m_ReaderFound = true;
                                SetUiEnabled(true, readerID.ReaderID); //TODO show more info? Also HW info?
                            }
                        }
                        else
                        {
                            //ReaderID check failed
                            readerCheckFailCount++;
                            if (readerCheckFailCount > 5)
                            {
                                //Reader Check failed multiple times
                                if (m_ReaderFound)
                                {
                                    //Previously found --> Asume Reader is lost!
                                    m_ReaderFound = false;
                                    SetUiEnabled(false, 0);
                                }
                            }
                            System.Threading.Thread.Sleep(200);
                        }
                    }
                }
            }
        }
        #endregion

        private void TelidControl_ReadLogProtocol_ProgressPercentageUpdated(object _source, int _percentage, TimeSpan _remaining)
        {
            Dispatcher.Invoke(() =>
            {
                progressBar.Value = _percentage;
                textBlock_TimeRemaining.Text = _remaining.ToString();
            });
        }

        private void Button_Search_Click(object sender, RoutedEventArgs e)
        {
            //Search --> Search for TELID® data loggers
            textBox_ResultRead.Text = "";
            progressBar.Value = 0;
            textBlock_TimeRemaining.Text = "";
            listBox_Measurements.ItemsSource = null;
            m_LastReadState = null;
            if (m_TelidControl != null)
            {
                if (m_TelidControl.IsInitialized)
                {
                    DateTime startTime = DateTime.UtcNow;
                    //This function blocks & searches for a default time of 1 second (optional parameter)
                    var scanResult = m_TelidControl.SearchForTELID();
                    TimeSpan processSpan = DateTime.UtcNow - startTime;
                    if (scanResult != null)
                    {
                        textBox_ResultRead.Text = "- TELID® found -\n";
                        textBox_ResultRead.Text += string.Format("SerNo: {0}\n", scanResult.SerialNumber);
                        textBox_ResultRead.Text += string.Format("Product-Type: {0}\n", scanResult.ProductType);
                        textBox_ResultRead.Text += "Physical-Data:\n";
                        foreach (var data in scanResult.PhyisicalData)
                        {
                            textBox_ResultRead.Text += string.Format("\t{0}\n", data);
                        }
                        
                        string toLog = string.Format("Result: OK. Duration: {0}\n", processSpan);
                        toLog += "- Sensor Result -\n";
                        toLog += string.Format("\tSerNo: {0}\n", scanResult.SerialNumber);
                        toLog += string.Format("\tProduct-Type: {0}\n", scanResult.ProductType);
                        textBox_ThreadLog.Text += toLog;
                        textBox_ThreadLog.ScrollToEnd();
                    }
                    else
                    {
                        //Update result in UI
                        textBox_ThreadLog.Text += string.Format("Result: FAIL. Duration: {0}\n", processSpan);
                        textBox_ThreadLog.ScrollToEnd();
                    }
                }
            }
        }

        private void Button_ReadStatus_Click(object sender, RoutedEventArgs e)
        {
            //ReadStatus --> Search for TELID® data logger and read its status
            textBox_ResultRead.Text = "";
            progressBar.Value = 0;
            textBlock_TimeRemaining.Text = "";
            listBox_Measurements.ItemsSource = null;
            m_LastReadState = null;
            if (m_TelidControl != null)
            {
                if (m_TelidControl.IsInitialized)
                {
                    DateTime startTime = DateTime.UtcNow;
                    //This function blocks & searches for a default time of 1 second (optional parameter)
                    var scanResult = m_TelidControl.SearchAndReadStatus();
                    TimeSpan processSpan = DateTime.UtcNow - startTime;
                    if (scanResult != null)
                    {
                        m_LastReadState = scanResult;
                        textBox_ResultRead.Text = "- TELID® found -\n";
                        var telidInfo = scanResult.VersionInfo;
                        textBox_ResultRead.Text += string.Format("SerNo: {0}\n", telidInfo.SerialNumber);
                        textBox_ResultRead.Text += string.Format("Product-Type: {0}\n", telidInfo.ProductType);
                        textBox_ResultRead.Text += "Physical-Data:\n";
                        foreach (var data in telidInfo.PhyisicalData)
                        {
                            textBox_ResultRead.Text += string.Format("\t{0}\n", data);
                        }
                        textBox_ResultRead.Text += string.Format("FW-Version: {0}\n", scanResult.FwVersion);
                        textBox_ResultRead.Text += string.Format("IsLogging: {0}\n", scanResult.IsLogging);
                        textBox_ResultRead.Text += string.Format("Programmed: {0}\n", scanResult.ProgrammedTime);
                        textBox_ResultRead.Text += string.Format("Start: {0}\n", scanResult.StartTime);
                        textBox_ResultRead.Text += string.Format("Stop: {0}\n", scanResult.StopTime);
                        textBox_ResultRead.Text += string.Format("Datasets: {0}\n", scanResult.NumberDatasetsLogged);
                        textBox_ResultRead.Text += string.Format("Mem-Percentage used: {0}\n", scanResult.MemoryPercentageUsed);
                        textBox_ResultRead.Text += "SensorParameters: \n";
                        textBox_ResultRead.Text += scanResult.SensorParameters.ToString();

                        string toLog = string.Format("Result: OK. Duration: {0}\n", processSpan);
                        toLog += "- Sensor Result -\n";
                        toLog += string.Format("\tSerNo: {0}\n", telidInfo.SerialNumber);
                        toLog += string.Format("\tProduct-Type: {0}\n", telidInfo.ProductType);
                        toLog += string.Format("\tIsLogging: {0}\n", scanResult.IsLogging);
                        toLog += string.Format("\tDatasets: {0}\n", scanResult.NumberDatasetsLogged);
                        textBox_ThreadLog.Text += toLog;
                        textBox_ThreadLog.ScrollToEnd();
                    }
                    else
                    {
                        //Update result in UI
                        textBox_ThreadLog.Text += string.Format("Result: FAIL. Duration: {0}\n", processSpan);
                        textBox_ThreadLog.ScrollToEnd();
                    }
                }
            }
        }

        private void Button_ReadLogProtocol_Click(object sender, RoutedEventArgs e)
        {
            //ReadLogProtocol --> Start ReadLog process
            textBox_ResultRead.Text = "";
            progressBar.Value = 0;
            textBlock_TimeRemaining.Text = "";
            listBox_Measurements.ItemsSource = null;
            if (m_LastReadState == null)
            {
                //No status data available! --> First read Status
                textBox_ResultRead.Text = "No TELID® status available --> press \"Read Status\"";
                return;
            }
            if (m_TelidControl != null)
            {
                if (m_TelidControl.IsInitialized)
                {
                    DateTime startTime = DateTime.UtcNow;
                    //This function blocks & reads the Log Protocol
                    var logResult = m_TelidControl.ReadLogProtocol(m_LastReadState);
                    TimeSpan processSpan = DateTime.UtcNow - startTime;
                    progressBar.Value = 100;
                    textBlock_TimeRemaining.Text = "";
                    if (logResult != null)
                    {
                        m_LastReadState = logResult;
                        textBox_ResultRead.Text = "- TELID® found -\n";
                        var telidInfo = logResult.VersionInfo;
                        textBox_ResultRead.Text += string.Format("SerNo: {0}\n", telidInfo.SerialNumber);
                        textBox_ResultRead.Text += string.Format("Product-Type: {0}\n", telidInfo.ProductType);
                        textBox_ResultRead.Text += "Physical-Data:\n";
                        foreach (var data in telidInfo.PhyisicalData)
                        {
                            textBox_ResultRead.Text += string.Format("\t{0}\n", data);
                        }
                        textBox_ResultRead.Text += string.Format("FW-Version: {0}\n", logResult.FwVersion);
                        textBox_ResultRead.Text += string.Format("IsLogging: {0}\n", logResult.IsLogging);
                        textBox_ResultRead.Text += string.Format("Programmed: {0}\n", logResult.ProgrammedTime);
                        textBox_ResultRead.Text += string.Format("Start: {0}\n", logResult.StartTime);
                        textBox_ResultRead.Text += string.Format("Stop: {0}\n", logResult.StopTime);
                        textBox_ResultRead.Text += string.Format("Datasets: {0}\n", logResult.NumberDatasetsLogged);
                        textBox_ResultRead.Text += string.Format("Mem-Percentage used: {0}\n", logResult.MemoryPercentageUsed);
                        textBox_ResultRead.Text += "SensorParameters: \n";
                        textBox_ResultRead.Text += logResult.SensorParameters.ToString();
                        textBox_ResultRead.Text += string.Format("\nMeasurements read: {0}\n", logResult.LoggedMeasurements.Length);
                        //populate ListBox
                        if (logResult.LoggedMeasurements != null)
                        {
                            List<MeasListboxItem> items = new List<MeasListboxItem>();
                            foreach (var meas in logResult.LoggedMeasurements)
                            {
                                string valuesStr = "";
                                foreach (var value in meas.Values)
                                {
                                    valuesStr += string.Format("{0}{1}", value.Magnitude, value.Unit) + "\t";
                                }
                                if (valuesStr.EndsWith("\t"))
                                    valuesStr = valuesStr.TrimEnd('\t');
                                items.Add(new MeasListboxItem()
                                {
                                    Timestamp = meas.Timestamp.ToString("yyyy-MM-dd HH:mm:ss"),
                                    Values = valuesStr,
                                    State = string.Format("{0}", meas.Status),
                                    BatState = string.Format("{0}", meas.BatState)
                                });
                            }
                            listBox_Measurements.ItemsSource = items;
                        }

                        string toLog = string.Format("Result: OK. Duration: {0}\n", processSpan);
                        toLog += "- ReadLog Result -\n";
                        toLog += string.Format("\tSerNo: {0}\n", telidInfo.SerialNumber);
                        toLog += string.Format("\tProduct-Type: {0}\n", telidInfo.ProductType);
                        toLog += string.Format("\tIsLogging: {0}\n", logResult.IsLogging);
                        toLog += string.Format("\tDatasets: {0}\n", logResult.NumberDatasetsLogged);
                        textBox_ThreadLog.Text += toLog;
                        textBox_ThreadLog.ScrollToEnd();
                    }
                    else
                    {
                        //Update result in UI
                        textBox_ThreadLog.Text += string.Format("Result: FAIL. Duration: {0}\n", processSpan);
                        textBox_ThreadLog.ScrollToEnd();
                    }
                }
            }
        }

        private void Button_Stop_Click(object sender, RoutedEventArgs e)
        {
            //Stop --> Stop current log
            textBox_ResultRead.Text = "";
            progressBar.Value = 0;
            textBlock_TimeRemaining.Text = "";
            listBox_Measurements.ItemsSource = null;
            if (m_LastReadState == null)
            {
                //No status data available! --> First read Status
                textBox_ResultRead.Text = "No TELID® status available --> press \"Read Status\"";
                return;
            }
            if (m_TelidControl != null)
            {
                if (m_TelidControl.IsInitialized)
                {
                    DateTime startTime = DateTime.UtcNow;
                    //This function blocks & searches for a default time of 1 second (optional parameter)
                    bool stopResult = m_TelidControl.StopLog(m_LastReadState);
                    TimeSpan processSpan = DateTime.UtcNow - startTime;
                    if (stopResult)
                    {
                        m_LastReadState = null;
                        textBox_ThreadLog.Text += string.Format("Result: OK. Duration: {0}\n", processSpan);
                        textBox_ThreadLog.ScrollToEnd();
                    }
                    else
                    {
                        //Update result in UI
                        textBox_ThreadLog.Text += string.Format("Result: FAIL. Duration: {0}\n", processSpan);
                        textBox_ThreadLog.ScrollToEnd();
                    }
                }
            }
        }

        private void Button_Restart_Click(object sender, RoutedEventArgs e)
        {
            textBox_ResultRead.Text = "";
            progressBar.Value = 0;
            textBlock_TimeRemaining.Text = "";
            listBox_Measurements.ItemsSource = null;
            if (m_LastReadState == null)
            {
                //No status data available! --> First read Status
                textBox_ResultRead.Text = "No TELID® status available --> press \"Read Status\"";
                return;
            }
            if (m_TelidControl != null)
            {
                if (m_TelidControl.IsInitialized)
                {
                    DateTime startTime = DateTime.UtcNow;
                    //This function blocks & searches for a default time of 1 second (optional parameter)

                    //TODO --> Use this for TELID300.nfc
                    bool startResult = m_TelidControl.RestartLog(
                        LogStartParameters.Initialize_TELID300nfc(
                            m_LastReadState,
                            "SampleCodeBlock_CSharp",
                            DateTime.Now.AddMinutes(5),
                            DateTime.Now.AddHours(1),
                            TELIDLibrary.Utils.SensorParameters.TELID300nfc_SensorParam.Initiailze(
                                TimeSpan.FromSeconds(30),
                                10,
                                30)));

                    //TODO --> Use this for TELID300v1 (For example TELID311)
                    //bool startResult = m_TelidControl.RestartLog(
                    //    LogStartParameters.Initialize_TELID300v1(
                    //        m_LastReadState,
                    //        "SampleCodeBlock_CSharp",
                    //        DateTime.Now.AddMinutes(5),
                    //        TELIDLibrary.Utils.SensorParameters.TELID311_SensorParam.Initiailze(
                    //            TimeSpan.FromSeconds(30),
                    //            10,
                    //            30)));

                    TimeSpan processSpan = DateTime.UtcNow - startTime;
                    if (startResult)
                    {
                        m_LastReadState = null;
                        textBox_ThreadLog.Text += string.Format("Result: OK. Duration: {0}\n", processSpan);
                        textBox_ThreadLog.ScrollToEnd();
                    }
                    else
                    {
                        //Update result in UI
                        textBox_ThreadLog.Text += string.Format("Result: FAIL. Duration: {0}\n", processSpan);
                        textBox_ThreadLog.ScrollToEnd();
                    }
                }
            }
        }
    }
}
