namespace PixelByProxy.VSWindow.Server.Firewall
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.EnableButton = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.PortLabel = new System.Windows.Forms.Label();
            this.NeverShowCheckBox = new System.Windows.Forms.CheckBox();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // EnableButton
            // 
            this.EnableButton.BackColor = System.Drawing.SystemColors.Control;
            this.EnableButton.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.EnableButton.Location = new System.Drawing.Point(311, 106);
            this.EnableButton.Name = "EnableButton";
            this.EnableButton.Size = new System.Drawing.Size(94, 36);
            this.EnableButton.TabIndex = 0;
            this.EnableButton.Text = "Enable";
            this.EnableButton.UseVisualStyleBackColor = false;
            this.EnableButton.Click += new System.EventHandler(this.EnableButton_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.White;
            this.label1.Location = new System.Drawing.Point(93, 12);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(305, 20);
            this.label1.TabIndex = 1;
            this.label1.Text = "Enable Firewall Rules for VS Window";
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::PixelByProxy.VSWindow.Server.Firewall.Properties.Resources.vswindow;
            this.pictureBox1.Location = new System.Drawing.Point(12, 12);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(75, 57);
            this.pictureBox1.TabIndex = 2;
            this.pictureBox1.TabStop = false;
            // 
            // PortLabel
            // 
            this.PortLabel.ForeColor = System.Drawing.Color.White;
            this.PortLabel.Location = new System.Drawing.Point(97, 36);
            this.PortLabel.Name = "PortLabel";
            this.PortLabel.Size = new System.Drawing.Size(301, 67);
            this.PortLabel.TabIndex = 3;
            // 
            // NeverShowCheckBox
            // 
            this.NeverShowCheckBox.AutoSize = true;
            this.NeverShowCheckBox.ForeColor = System.Drawing.Color.White;
            this.NeverShowCheckBox.Location = new System.Drawing.Point(12, 124);
            this.NeverShowCheckBox.Name = "NeverShowCheckBox";
            this.NeverShowCheckBox.Size = new System.Drawing.Size(165, 17);
            this.NeverShowCheckBox.TabIndex = 4;
            this.NeverShowCheckBox.Text = "Never show this dialog again.";
            this.NeverShowCheckBox.UseVisualStyleBackColor = true;
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(122)))), ((int)(((byte)(204)))));
            this.ClientSize = new System.Drawing.Size(415, 153);
            this.Controls.Add(this.NeverShowCheckBox);
            this.Controls.Add(this.PortLabel);
            this.Controls.Add(this.pictureBox1);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.EnableButton);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "Form1";
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "VS Window";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Form1_FormClosing);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button EnableButton;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Label PortLabel;
        private System.Windows.Forms.CheckBox NeverShowCheckBox;
    }
}

