using System;
using System.Globalization;
using System.Windows.Forms;
using PixelByProxy.VSWindow.Server.Shared;

namespace PixelByProxy.VSWindow.Server.UI
{
	/// <summary>
	/// This class implements UI for the Custom options page.
    /// It uses OptionsPageCustom object as a data objects.
	/// </summary>
	public class OptionsGeneralControl : UserControl
	{
        #region Fields
        // ReSharper disable InconsistentNaming
        private Label label1;
        private TextBox PasswordTextBox;
        private GroupBox groupBox1;
        private Label label3;
        private TextBox PortTextBox;
        private Label label2;
        private ErrorProvider FormErrorProvider;
        private Label StatusLabel;
        private Label label4;
        private Label label6;
        private Label label5;
        private TextBox SignalPortTextBox;
        private System.ComponentModel.IContainer components;
        // ReSharper restore InconsistentNaming
        #endregion

        #region Constructors
        /// <summary>
        /// Explicitly defined default constructor.
        /// Initializes new instance of OptionsCompositeControl class.
        /// </summary>
        public OptionsGeneralControl()
        {
            // This call is required by the Windows.Forms Form Designer.
            InitializeComponent();
        }
        #endregion

        #region Methods

        #region IDisposable implementation
        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (components != null)
                {
                    components.Dispose();
                }
                GC.SuppressFinalize(this);
            }
            base.Dispose(disposing);
        }
        #endregion

        #region Component Designer generated code
        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.label1 = new System.Windows.Forms.Label();
            this.PasswordTextBox = new System.Windows.Forms.TextBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.label6 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.StatusLabel = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.PortTextBox = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.SignalPortTextBox = new System.Windows.Forms.TextBox();
            this.FormErrorProvider = new System.Windows.Forms.ErrorProvider(this.components);
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.FormErrorProvider)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(11, 54);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(29, 13);
            this.label1.TabIndex = 99;
            this.label1.Text = "Port:";
            // 
            // PasswordTextBox
            // 
            this.PasswordTextBox.Location = new System.Drawing.Point(90, 77);
            this.PasswordTextBox.MaxLength = 100;
            this.PasswordTextBox.Name = "PasswordTextBox";
            this.PasswordTextBox.PasswordChar = '*';
            this.PasswordTextBox.Size = new System.Drawing.Size(100, 20);
            this.PasswordTextBox.TabIndex = 2;
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.label6);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.StatusLabel);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.PortTextBox);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Controls.Add(this.PasswordTextBox);
            this.groupBox1.Controls.Add(this.label1);
            this.groupBox1.Controls.Add(this.SignalPortTextBox);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox1.Location = new System.Drawing.Point(0, 0);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(387, 280);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Connection Settings";
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.ForeColor = System.Drawing.Color.Red;
            this.label6.Location = new System.Drawing.Point(73, 106);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(11, 13);
            this.label6.TabIndex = 102;
            this.label6.Text = "*";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(11, 106);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(61, 13);
            this.label5.TabIndex = 101;
            this.label5.Text = "Signal Port:";
            // 
            // StatusLabel
            // 
            this.StatusLabel.AutoSize = true;
            this.StatusLabel.Location = new System.Drawing.Point(87, 28);
            this.StatusLabel.Name = "StatusLabel";
            this.StatusLabel.Size = new System.Drawing.Size(79, 13);
            this.StatusLabel.TabIndex = 99;
            this.StatusLabel.Text = "Not Connected";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(11, 28);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(40, 13);
            this.label4.TabIndex = 99;
            this.label4.Text = "Status:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.ForeColor = System.Drawing.Color.Red;
            this.label3.Location = new System.Drawing.Point(40, 54);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(11, 13);
            this.label3.TabIndex = 99;
            this.label3.Text = "*";
            // 
            // PortTextBox
            // 
            this.PortTextBox.Location = new System.Drawing.Point(90, 51);
            this.PortTextBox.MaxLength = 5;
            this.PortTextBox.Name = "PortTextBox";
            this.PortTextBox.Size = new System.Drawing.Size(100, 20);
            this.PortTextBox.TabIndex = 1;
            this.PortTextBox.Validated += new System.EventHandler(this.PortTextBox_Validated);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(11, 80);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(56, 13);
            this.label2.TabIndex = 99;
            this.label2.Text = "Password:";
            // 
            // SignalPortTextBox
            // 
            this.SignalPortTextBox.Location = new System.Drawing.Point(90, 103);
            this.SignalPortTextBox.MaxLength = 100;
            this.SignalPortTextBox.Name = "SignalPortTextBox";
            this.SignalPortTextBox.Size = new System.Drawing.Size(100, 20);
            this.SignalPortTextBox.TabIndex = 3;
            this.SignalPortTextBox.Validated += new System.EventHandler(this.SignalPortTextBox_Validated);
            // 
            // FormErrorProvider
            // 
            this.FormErrorProvider.ContainerControl = this;
            // 
            // OptionsGeneralControl
            // 
            this.AllowDrop = true;
            this.Controls.Add(this.groupBox1);
            this.Name = "OptionsGeneralControl";
            this.Size = new System.Drawing.Size(387, 280);
            this.Load += new System.EventHandler(this.Control_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.FormErrorProvider)).EndInit();
            this.ResumeLayout(false);

        }
        #endregion

        #endregion

        #region Public Properties
	    /// <summary>
	    /// Gets or Sets the reference to the underlying OptionsPage object.
	    /// </summary>
	    public OptionsPageGeneral OptionsPage { get; set; }
        public int Port
	    {
	        get
	        {
                int port;

                if (!int.TryParse(PortTextBox.Text, out port))
                {
                    port = 0;
                }

	            return port;
	        }
            set { PortTextBox.Text = value.ToString(CultureInfo.CurrentCulture); }
	    }
        public int SignalPort
        {
            get
            {
                int port;

                if (!int.TryParse(SignalPortTextBox.Text, out port))
                {
                    port = 0;
                }

                return port;
            }
            set { SignalPortTextBox.Text = value.ToString(CultureInfo.CurrentCulture); }
        }
        public string Password
        {
            get { return PasswordTextBox.Text; }
            set { PasswordTextBox.Text = value; }
        }
        public string ServiceStatusText
        {
            get { return StatusLabel.Text; }
            set
            {
                if (StatusLabel.InvokeRequired)
                {
                    StatusLabel.Invoke(new MethodInvoker(delegate { StatusLabel.Text = value; }));
                }
                else
                {
                    StatusLabel.Text = value;
                }
            }
        }
        public bool IsValid
        {
            get { return IsPortValid(PortTextBox) && IsPortValid(SignalPortTextBox); }
        }
        public string ErrorMessage
        {
            get
            {
                string error = FormErrorProvider.GetError(PortTextBox);

                if (!string.IsNullOrEmpty(error))
                    error = string.Concat(error, Environment.NewLine);

                error = string.Concat(error, FormErrorProvider.GetError(SignalPortTextBox));

                return error;
            }
        }
        #endregion

        #region Event Methods
        private void Control_Load(object sender, EventArgs e)
        {
            PortTextBox.Text = ServerSettings.SocketPort.ToString(CultureInfo.CurrentCulture);
            PasswordTextBox.Text = ServerSettings.SocketPassword;
            SignalPortTextBox.Text = ServerSettings.SignalPort.ToString(CultureInfo.CurrentCulture);
        }
        private void PortTextBox_Validated(object sender, EventArgs e)
        {
            IsPortValid(PortTextBox);
        }
        private void SignalPortTextBox_Validated(object sender, EventArgs e)
        {
            IsPortValid(SignalPortTextBox);
        }
        #endregion

        #region Private Methods
        private bool IsPortValid(TextBox textBox)
        {
            FormErrorProvider.Clear();

            bool isValid = false;
            int port;

            if (int.TryParse(textBox.Text, out port) && port > 0 && port <= 65535)
            {
                isValid = true;
            }

            if (!isValid)
            {
                FormErrorProvider.SetError(textBox, textBox == SignalPortTextBox ? "The signal port is not valid." : "The port is not valid.");
            }

            return isValid;
        }
        #endregion
	}
}