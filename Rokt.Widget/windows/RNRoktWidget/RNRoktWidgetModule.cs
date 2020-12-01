using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Rokt.Widget.RNRoktWidget
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNRoktWidgetModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNRoktWidgetModule"/>.
        /// </summary>
        internal RNRoktWidgetModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNRoktWidget";
            }
        }
    }
}
