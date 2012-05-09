using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Collections;
using OpenTK.Graphics;
using OpenTK.Graphics.OpenGL;

// The Microsoft Tablet PC namespaces
using Microsoft.StylusInput;
using Microsoft.StylusInput.PluginData;
using Microsoft.Ink;


namespace Tangible_Learning
{
    public partial class TangibleRecognizerForm : Form, IStylusAsyncPlugin
    {
        private int counter = 0;
        private RealTimeStylus myRealTimeStylus; private RealTimeStylus myRealTimeStylus1;
        private DynamicRenderer myDynamicRenderer;
        private Renderer myRenderer;
        private Hashtable tangiblePattern, touchesOnScreen;
        private Ink myInk;
        private Graphics graphics;
        private ArrayList arrayOfTangibleObjects;
        private int leftLineX, topLineY, rightLineX, bottomLineY;
        private TangibleObject recognizedTangible;
        private Point[] pointsToDraw;
        TRPoint prevPoint;
        TRRecognizer recognizer;
        int TangibleArrayIndex = 0;
        int previousnumber = 0;
        
        public TangibleRecognizerForm()
        {
            InitializeComponent();
        }

       

        private void TangibleRecognizerForm_Load(object sender, EventArgs e)
        {
            recognizer = new TRRecognizer();
            arrayOfTangibleObjects = new ArrayList();

            //Default Values for LearningPhase Lines
            leftLineX = 10;
            rightLineX = glLearningView.Width - 10;
            topLineY = 10;
            bottomLineY = glLearningView.Height - 10;

            tangiblePattern = new Hashtable();
            touchesOnScreen = new Hashtable();
            graphics = glLearningView.CreateGraphics();
            //myDynamicRenderer = new DynamicRenderer(LearningPhasePictureBox);
            //myRenderer = new Renderer();
            myRealTimeStylus = new RealTimeStylus(glLearningView, true);
            //myRealTimeStylus.SyncPluginCollection.Add(myDynamicRenderer);
            myRealTimeStylus.AsyncPluginCollection.Add(this);
            myRealTimeStylus.MultiTouchEnabled = true;
            myRealTimeStylus.Enabled = true; 
            myRealTimeStylus1 = new RealTimeStylus(glDrawingView, true);
            //myRealTimeStylus.SyncPluginCollection.Add(myDynamicRenderer);
            myRealTimeStylus1.AsyncPluginCollection.Add(this);
            myRealTimeStylus1.MultiTouchEnabled = true;
            myRealTimeStylus1.Enabled = true;
            //myDynamicRenderer.Enabled = true;
            


        }
        private void LearningPhasePictureBox_Paint(object sender, System.Windows.Forms.PaintEventArgs e)
        {
            //myDynamicRenderer.Refresh();
            //myRenderer.Draw(e.Graphics, myInk.Strokes);
            ///LearningPhasePanel.Refresh();
            Pen myPen = new Pen(System.Drawing.Color.Blue, 3);
            //Draw LeftLine
            e.Graphics.DrawLine(myPen, leftLineX, 0, leftLineX, glLearningView.Height);
            //Draw RightLine
            e.Graphics.DrawLine(myPen, rightLineX, 0, rightLineX, glLearningView.Height);
            //Draw TopLine
            e.Graphics.DrawLine(myPen, 0, topLineY, glLearningView.Width, topLineY);
            //Draw BottomLine
            e.Graphics.DrawLine(myPen, 0, bottomLineY, glLearningView.Width, bottomLineY);
            

        }

        private void glDrawingView_Paint(object sender, System.Windows.Forms.PaintEventArgs e)
        {
            //myDynamicRenderer.Refresh();
            //myRenderer.Draw(e.Graphics, myInk.Strokes);
            ///LearningPhasePanel.Refresh();
            Pen myPen = new Pen(System.Drawing.Color.Blue, 3);


            
            if (recognizedTangible != null)
            {
               
                if (recognizedTangible.type.Equals(TangibleType.Ruler))
                {
                    glDrawingView.MakeCurrent();
                    GL.MatrixMode(MatrixMode.Modelview);
                    GL.LoadIdentity();
                    GL.Color3(Color.Blue);
                    GL.LineWidth(2);
                    GL.ClearColor(Color.Green);
                    GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit);
                    GL.Begin(BeginMode.Lines);
                    GL.Vertex2(pointsToDraw[0].X, pointsToDraw[0].Y);
                    GL.Vertex2(pointsToDraw[1].X, pointsToDraw[1].Y);

                    GL.Vertex2(pointsToDraw[1].X, pointsToDraw[1].Y);
                    GL.Vertex2(pointsToDraw[2].X, pointsToDraw[2].Y);

                    GL.Vertex2(pointsToDraw[2].X, pointsToDraw[2].Y);
                    GL.Vertex2(pointsToDraw[3].X, pointsToDraw[3].Y);

                    GL.Vertex2(pointsToDraw[3].X, pointsToDraw[3].Y);
                    GL.Vertex2(pointsToDraw[0].X, pointsToDraw[0].Y);
                  
                    GL.End();
                    GL.Finish();
                    glDrawingView.SwapBuffers();
                    return;
                    
                }
            }
            
            
        }
        public void drawRecognizedObject(VectorInt recognizedObjectVector)
        {
            for (int i = 1; i < recognizedObjectVector.Count(); i++)
            {

                recognizedTangible = (TangibleObject)arrayOfTangibleObjects[recognizedObjectVector[i]];
                label1.Text = "abc" + recognizedTangible.type.ToString();
                Console.WriteLine(recognizedObjectVector[i].ToString());
                
                
                if (recognizedTangible.type.Equals(TangibleType.Ruler))
                {
                    TRTangibleObject tobj = recognizer.getTangibleObjectForId(recognizedObjectVector[i]);
                    float rot = -tobj.getRotation();
                    TRPoint tran = tobj.getTranslation();
                    //Graphics g = DrawingTab.CreateGraphics();
                    tran.x = (int)Math.Round((float)tran.x * (float)glDrawingView.CreateGraphics().DpiX / 2540.0F);
                    tran.y = (int)Math.Round((float)tran.y * (float)glDrawingView.CreateGraphics().DpiY / 2540.0F);
                    float m11, m12, m21, m22;
                    m11 = (float)Math.Cos(rot);
                    m12 = (float)-Math.Sin(rot);
                    m21 = (float)Math.Sin(rot);
                    m22 = (float)Math.Cos(rot);
                    Matrix m = new Matrix(m11, m12, m21, m22, tran.x, tran.y);

                    ArrayList points = (ArrayList)recognizedTangible.outlinePoints.Clone();
                    pointsToDraw = (Point[])points.ToArray(typeof(Point));
                    m.TransformPoints(pointsToDraw);
                    
                  // Console.WriteLine(tobj.getRotation());
                    //Console.WriteLine(tran.x + ":" + tran.y);
                    glDrawingView.Invalidate();

                }label2.Text = "";
            }
            

        }
        public DataInterestMask DataInterest
        {
            get
            {
                return DataInterestMask.StylusUp | DataInterestMask.StylusDown | DataInterestMask.Packets | DataInterestMask.Error;
            }

        }
        public void StylusDown(RealTimeStylus sender, StylusDownData data)
        {
            Tablet tablet = sender.GetTabletFromTabletContextId(data.Stylus.TabletContextId);
            TRPoint point = new TRPoint();
            point.x = data[0]; point.y = data[1];
            // Since the packet data is in Ink Space coordinates, we need to convert to Pixels...
            point.x = (int)Math.Round((float)point.x * (float)graphics.DpiX / 2540.0F);
            point.y = (int)Math.Round((float)point.y * (float)graphics.DpiY / 2540.0F);
            switch (tablet.DeviceKind)
            {
                case TabletDeviceKind.Mouse:
                   
                case TabletDeviceKind.Pen:
                    if (TangibleRecognizerTab.SelectedTab.Equals(LearningPhaseTab))
                    {
                        if (Math.Abs(point.x - leftLineX) <= 10)
                        {
                            prevPoint = point;
                        }
                        else if (Math.Abs(point.x - rightLineX) <= 10)
                        {
                            prevPoint = point;
                        }
                        else if (Math.Abs(point.y - topLineY) <= 10)
                        {
                            prevPoint = point;
                        }
                        else if (Math.Abs(point.y - bottomLineY) <= 10)
                        {
                            prevPoint = point;
                        }
                    }
                    break;
                case TabletDeviceKind.Touch:
                    TRPoint touchPoint = new TRPoint();
                    touchPoint.x = data[0];
                    touchPoint.y = data[1];
                
                    touchesOnScreen.Add(data.Stylus.Id, touchPoint);
                    tangiblePattern = (Hashtable) touchesOnScreen.Clone();
                    label1.Text = tangiblePattern.Count.ToString();
                    if (TangibleRecognizerTab.SelectedTab.Equals(DrawingTab))
                    {
                        recognizer.touchBegan(data.Stylus.Id, touchPoint);
                        VectorInt recognizedIndex = recognizer.getRecognizedObject();
                        if (recognizedIndex.Count > 0)
                        {
                            drawRecognizedObject(recognizedIndex);
                        }

                    }
                    break;
            }


        }
        public void Packets(RealTimeStylus sender, PacketsData data)
        {
            //((ArrayList)(myPackets[data.Stylus.Id])).AddRange(data.GetData());
            Tablet tablet = sender.GetTabletFromTabletContextId(data.Stylus.TabletContextId);
            if (previousnumber == data.Stylus.Id)
            {
               // Console.WriteLine(data.Stylus.Id);
            }
            previousnumber = data.Stylus.Id;
            switch (tablet.DeviceKind)
            {
                case TabletDeviceKind.Mouse:
                   
                    
                case TabletDeviceKind.Pen:
                    TRPoint point = new TRPoint();
                    point.x = data[0]; point.y = data[1];
                    // Since the packet data is in Ink Space coordinates, we need to convert to Pixels...
                    point.x = (int)Math.Round((float)point.x * (float)graphics.DpiX / 2540.0F);
                    point.y = (int)Math.Round((float)point.y * (float)graphics.DpiY / 2540.0F);
                    if(TangibleRecognizerTab.SelectedTab.Equals(LearningPhaseTab))
                    {
                        if (prevPoint == null)
                            return;
                        if (Math.Abs(leftLineX - prevPoint.x) <= 10)
                        {
                            leftLineX = (int)point.x;
                            prevPoint = point;
                            this.glLearningView.Invalidate();
                        }else if (Math.Abs(rightLineX - prevPoint.x) <= 10)
                        {
                            rightLineX = (int)point.x;
                            prevPoint = point;
                            this.glLearningView.Invalidate();
                        }
                        else if (Math.Abs(topLineY - prevPoint.y) <= 10)
                        {
                            topLineY = (int)point.y;
                            prevPoint = point;
                            this.glLearningView.Invalidate();
                        }
                        else if (Math.Abs(bottomLineY - prevPoint.y) <= 10)
                        {
                            bottomLineY = (int)point.y;
                            prevPoint = point;
                            this.glLearningView.Invalidate();
                        }
                    }
                    break;
                case TabletDeviceKind.Touch:
                    TRPoint touchPoint = new TRPoint();
                    touchPoint.x = data[0];
                    touchPoint.y = data[1];

                    if (TangibleRecognizerTab.SelectedTab.Equals(DrawingTab))
                    {
                        if (previousnumber == data.Stylus.Id)
                        {
                   //         return;
                        }
                        counter++;
                        if (counter % 5 == 0)
                        {
                            //Console.WriteLine(touchPoint.x + ":" + touchPoint.y);
                            recognizer.touchMoved(data.Stylus.Id, touchPoint);
                            VectorInt recognizedIndex = recognizer.getRecognizedObject();
                            if (recognizedIndex.Count > 0)
                            {
                                drawRecognizedObject(recognizedIndex);

                            }
                        }
                    }
                    break;
            }
           /* Tablet t = sender.GetTabletFromTabletContextId(data.Stylus.TabletContextId);
            if (sender.GetTabletFromTabletContextId(data.Stylus.TabletContextId).DeviceKind == TabletDeviceKind.Mouse)
            {
                Point point = new Point(data[0], data[1]);
                graphics.DrawEllipse(Pens.Red, point.X / 26, point.Y / 28, 10, 10);

            }*/
        }
        public void StylusUp(RealTimeStylus sender, StylusUpData data)
        {

            if(touchesOnScreen.ContainsKey(data.Stylus.Id)){
                touchesOnScreen.Remove(data.Stylus.Id);
            }
            label1.Text = "u " + tangiblePattern.Count.ToString();
            Tablet tablet = sender.GetTabletFromTabletContextId(data.Stylus.TabletContextId);
            switch (tablet.DeviceKind)
            {
                case TabletDeviceKind.Mouse:
                    
                case TabletDeviceKind.Pen:
                    if (prevPoint == null)
                        return;
                    prevPoint.x = 0;
                    prevPoint.y = 0;
                    break;
                case TabletDeviceKind.Touch:
                    TRPoint touchPoint = new TRPoint();
                    touchPoint.x = data[0];
                    touchPoint.y = data[1];
                    
                    if (TangibleRecognizerTab.SelectedTab.Equals(DrawingTab))
                    {
                        recognizer.touchEnded(data.Stylus.Id, touchPoint);
                    }

                    break;
            }
           /* ArrayList collectedPackets = (ArrayList)myPackets[data.Stylus.Id];
            myPackets.Remove(data.Stylus.Id);

            collectedPackets.AddRange(data.GetData());

            int[] packets = (int[])(collectedPackets.ToArray(typeof(int)));
            TabletPropertyDescriptionCollection tabletProperties =
                myRealTimeStylus.GetTabletPropertyDescriptionCollection(data.Stylus.TabletContextId);
            Stroke stroke = myInk.CreateStroke(packets, tabletProperties);
            if (stroke != null)
            {
                stroke.DrawingAttributes.Color = myDynamicRenderer.DrawingAttributes.Color;
                stroke.DrawingAttributes.Width = myDynamicRenderer.DrawingAttributes.Width;
            }*/
        }

        public void CustomStylusDataAdded(RealTimeStylus sender, CustomStylusData data){}
        public void Error(RealTimeStylus sender, ErrorData data) { }
        public void RealTimeStylusDisabled(RealTimeStylus sender, RealTimeStylusDisabledData data) { }
        public void RealTimeStylusEnabled(RealTimeStylus sender, RealTimeStylusEnabledData data) { }
        public void StylusOutOfRange(RealTimeStylus sender, StylusOutOfRangeData data) { }
        public void StylusInRange(RealTimeStylus sender, StylusInRangeData data) { }
        public void StylusButtonDown(RealTimeStylus sender, StylusButtonDownData data) { }
        public void StylusButtonUp(RealTimeStylus sender, StylusButtonUpData data) { }
        public void SystemGesture(RealTimeStylus sender, SystemGestureData data) { }
        public void InAirPackets(RealTimeStylus sender, InAirPacketsData data) { }
        public void TabletAdded(RealTimeStylus sender, TabletAddedData data) { }
        public void TabletRemoved(RealTimeStylus sender, TabletRemovedData data) { }

        private void RulerButton_Click(object sender, EventArgs e)
        {
            if (tangiblePattern.Count < 2) { return; } //LET THEM KNOW IT DIDNT ADD
            ArrayList outlinePoints = new ArrayList();
            outlinePoints.Add(new Point(leftLineX,topLineY));
            outlinePoints.Add(new Point(rightLineX,topLineY));
            outlinePoints.Add(new Point(rightLineX,bottomLineY));
            outlinePoints.Add(new Point(leftLineX,bottomLineY));
            VectorTRPoint patternPoints = new VectorTRPoint();
            foreach (int i in tangiblePattern.Keys)
            {
                patternPoints.Add((TRPoint)tangiblePattern[i]);
            }
            label1.Text = "b " + tangiblePattern.Count.ToString();
            tangiblePattern.Clear();
            Matrix m = new Matrix();
            TRGraph graph = new TRGraph(patternPoints);
            TRTangibleObject tObj = new TRTangibleObject(TangibleArrayIndex, graph);
            recognizer.addTangibleObject(tObj);
            TangibleObject tangibleObj = new TangibleObject(outlinePoints, tObj, m, TangibleType.Ruler);
            arrayOfTangibleObjects.Add(tangibleObj);
            TangibleArrayIndex++;
   
        }        
        private void glLearningView_Load(object sender, EventArgs e)
        {
            GL.ClearColor(Color.White);
            SetupViewport();
        }


        private void SetupViewport()
        {
            int w = glLearningView.Width;
            int h = glLearningView.Height;
            GL.MatrixMode(MatrixMode.Projection);
            GL.LoadIdentity();
            GL.Ortho(0, w, h, 0, -1, 1); // Bottom-left corner pixel has coordinate (0, 0)
            GL.Viewport(0, 0, w, h); // Use all of the glControl painting area
        }
        private void glLearningView_Paint(object sender, PaintEventArgs e)
        {
          glLearningView.MakeCurrent();
          GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit);
          GL.MatrixMode(MatrixMode.Modelview);
          GL.LoadIdentity();
          GL.Color3(Color.Blue);
          GL.LineWidth(2);
          GL.Begin(BeginMode.Lines);
          GL.Vertex2(leftLineX, 0);
          GL.Vertex2(leftLineX, glLearningView.Height);
          GL.Vertex2(rightLineX, 0);
          GL.Vertex2(rightLineX, glLearningView.Height);
          GL.Vertex2(0, topLineY);
          GL.Vertex2(glLearningView.Width, topLineY);
          GL.Vertex2(0, bottomLineY);
          GL.Vertex2(glLearningView.Width, bottomLineY);
          GL.End();
          GL.Finish();
          glLearningView.SwapBuffers();
        
         
                                                       
        }

        private void glDrawingView_Load(object sender, EventArgs e)
        {
            glDrawingView.MakeCurrent();
            GL.ClearColor(Color.WhiteSmoke);
            int w = glDrawingView.Width;
            int h = glDrawingView.Height;
            GL.MatrixMode(MatrixMode.Projection);
            GL.LoadIdentity();
            GL.Ortho(0, w, h, 0, -1, 1); // Bottom-left corner pixel has coordinate (0, 0)
            GL.Viewport(0, 0, w, h);
        }
    }
}


enum TangibleType { Ruler, SetSquare, Protractor, Circle, Triangle };


class TangibleObject
{
    public ArrayList outlinePoints;
    public TRTangibleObject TRObject;
    public Matrix transformation;
    public TangibleType type;

    public TangibleObject(ArrayList outlinePoints, TRTangibleObject patternPoints, Matrix transformation, TangibleType type)
    {
        this.outlinePoints = outlinePoints;
        this.TRObject = patternPoints;
        this.transformation = transformation;
        this.type = type;

    }

    public void update()
    {
        float rot = TRObject.getRotation();
        TRPoint tran = TRObject.getTranslation();

        tran.x = (int)Math.Round((float)tran.x * (float)96 / 2540.0F);
        tran.y = (int)Math.Round((float)tran.y * (float)96 / 2540.0F);
        transformation.Rotate(rot);
        transformation.Translate(tran.x, tran.y);
    }

}
