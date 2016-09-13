using System;
using System.CodeDom;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Threading;

using Looksfamiliar.d2c2d.MessageModels;
using LooksFamiliar.Microservices.Provision.SDK;
using Microsoft.Azure.Devices;
using Microsoft.ServiceBus.Messaging;
using Newtonsoft.Json;
using Microsoft.Maps.MapControl.WPF;
using Microsoft.Maps.MapControl.WPF.Core;
using Location = Microsoft.Maps.MapControl.WPF.Location;
using TransportType = Microsoft.Azure.Devices.TransportType;

namespace Looksfamiliar.D2C2D.Dashboard
{

    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private readonly QueueClient _messageClient;
        private readonly QueueClient _alarmClient;
        private ServiceClient _serviceClient;
        private ProvisionM _provisionM;
        private DeviceManifest _currDevice;

        public MainWindow()
        {
            InitializeComponent();

            _messageClient = QueueClient.CreateFromConnectionString(ConfigurationManager.AppSettings["ServiceBusConnStr"], "messagedrop");
            _alarmClient = QueueClient.CreateFromConnectionString(ConfigurationManager.AppSettings["ServiceBusConnStr"], "alarms");
            _serviceClient = ServiceClient.CreateFromConnectionString(ConfigurationManager.AppSettings["IoTHubConnStr"], TransportType.Amqp);

            _provisionM = new ProvisionM
            {
                ApiUrl = ConfigurationManager.AppSettings["ProvisionAPI"],
                DevKey = ConfigurationManager.AppSettings["DeveloperKey"]
            };
        }

        private void MainWindow_OnLoaded(object sender, RoutedEventArgs e)
        {
            GetDeviceList();

            if (DeviceList.Items.Count == 0)
            {
                StartButton.IsEnabled = false;
                StopButton.IsEnabled = false;
                PingButton.IsEnabled = false;
            }
        }

        private void StartButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private void StopButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private async void ProvisionButton_Click(object sender, RoutedEventArgs e)
        {
            var location = await GetLocationAsync();

            // initialize a device manifest
            var manifest = new DeviceManifest
            {
                latitude = location.lat,
                longitude = location.lon,
                manufacturer = "Looksfamiliar, Inc",
                model = "Weather Station - Win 10 Core IoT",
                firmwareversion = "1.0.0.0",
                version = "1.0.0.0",
                hub = ConfigurationManager.AppSettings["IoTHubName"],
                serialnumber = "d2c2d-" + Guid.NewGuid()
            };

            manifest.properties.Add(new DeviceProperty("Hardware Platform", "Raspberry PI"));

            // provision the device in IoT Hub and store the manifest in DocumentDb
            manifest = _provisionM.Create(manifest);

            MessageBox.Show($"New Device Provisioned: {manifest.serialnumber}", "Confirmation", MessageBoxButton.OK);
            DeviceList.Items.Clear();

            var devices = _provisionM.GetAll();

            foreach (var device in devices.list) { DeviceList.Items.Add(device.serialnumber); }

            if (DeviceList.Items.Count <= 0) return;

            StartButton.IsEnabled = true; StopButton.IsEnabled = true; PingButton.IsEnabled = true;
        }


        private void GetDeviceList()
        {
            var devices = _provisionM.GetAll();

            foreach (var device in devices.list)
            {
                if (device.serialnumber != "")
                {
                    DeviceList.Items.Add(device.serialnumber);
                }
            }

            if (DeviceList.HasItems)
            {
                DeviceList.SelectedIndex = 0;
            }
        }

        private static async Task<d2c2d.MessageModels.Location> GetLocationAsync()
        {
            var client = new HttpClient();
            var json = await client.GetStringAsync("http://ip-api.com/json");
            var location = JsonConvert.DeserializeObject<d2c2d.MessageModels.Location>(json);
            return location;
        }

        private void DeviceList_OnSelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (DeviceList.Items.Count == 0) return;
            var deviceId = (string)DeviceList.SelectedItems[0];
            PingFeed.Clear();
            TelemetryFeed.Clear();
            AlarmFeed.Clear();
            _currDevice = _provisionM.GetById(deviceId);
        }
    }
}
